package main

import (
	"flag"
	"fmt"
	"gopkg.in/yaml.v2"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

// Config struct to hold Jenkins configuration
type Config struct {
	Jenkins struct {
		URL      string `yaml:"url"`
		Username string `yaml:"username"`
		Token    string `yaml:"token"`
	} `yaml:"jenkins"`
}

func main() {
	// Command-line flags
	configFile := flag.String("config", "config.yaml", "Path to the configuration file")
	jobName := flag.String("job", "", "Jenkins job name")
	paramsSlice := keyValueSlice{}
	flag.Var(&paramsSlice, "params", "Build parameters in the form key1=value1[,key2=value2,...], multiple allowed")

	// Parse command-line flags
	flag.Parse()

	// Read configuration from file
	config, err := readConfig(*configFile)
	if err != nil {
		fmt.Printf("Error reading config file: %v\n", err)
		os.Exit(1)
	}

	// Merge parameters from file and command line
	parameters := mergeParameters(config, paramsSlice)

	// Trigger the parameterized build
	err = triggerParameterizedBuild(config.Jenkins.URL, *jobName, config.Jenkins.Username, config.Jenkins.Token, parameters)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}

type keyValue struct {
	Key   string
	Value string
}

type keyValueSlice []keyValue

func (s *keyValueSlice) String() string {
	var result string
	for _, kv := range *s {
		result += fmt.Sprintf("%s=%s ", kv.Key, kv.Value)
	}
	return result
}

func (s *keyValueSlice) Set(value string) error {
	pairs := strings.Split(value, ",")
	for _, pair := range pairs {
		keyValue := keyValue{}
		parts := strings.SplitN(pair, "=", 2)
		if len(parts) != 2 {
			return fmt.Errorf("invalid format for key-value pair: %s", value)
		}
		keyValue.Key = parts[0]
		keyValue.Value = parts[1]
		*s = append(*s, keyValue)
	}
	return nil
}

func readConfig(file string) (*Config, error) {
	data, err := ioutil.ReadFile(file)
	if err != nil {
		return nil, err
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}

func mergeParameters(config *Config, paramsSlice keyValueSlice) map[string][]string {
	parameters := make(map[string][]string)

	// Add parameters from file
	for key, value := range map[string]string{"url": config.Jenkins.URL, "username": config.Jenkins.Username, "token": config.Jenkins.Token} {
		parameters[key] = append(parameters[key], value)
	}

	// Add parameters from command line
	for _, kv := range paramsSlice {
		parameters[kv.Key] = append(parameters[kv.Key], kv.Value)
	}

	return parameters
}

func triggerParameterizedBuild(jenkinsURL, jobName, username, token string, parameters map[string][]string) error {
	// Jenkins API endpoint for triggering builds with parameters
	buildURL := fmt.Sprintf("%s/job/%s/buildWithParameters", jenkinsURL, jobName)

	// Print the full URL with parameters
	fmt.Printf("Triggering build at URL: %s\n", buildURL)

	// Prepare the HTTP request
	req, err := http.NewRequest("POST", buildURL, nil)
	if err != nil {
		return err
	}

	// Set Jenkins authentication
	req.SetBasicAuth(username, token)

	// Flatten multiple values into a comma-separated string
	for key, values := range parameters {
		req.Header.Add(key, strings.Join(values, ","))
	}

	// Perform the HTTP request
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Check the response status
	if resp.StatusCode == http.StatusCreated {
		fmt.Println("Build triggered successfully!")
		return nil
	} else {
		fmt.Printf("Failed to trigger build. Status code: %d\n", resp.StatusCode)
		return fmt.Errorf("failed to trigger build")
	}
}
