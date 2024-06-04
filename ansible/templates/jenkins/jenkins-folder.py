import configparser
import re

import click
import requests


# Fungsi untuk membaca konfigurasi dari file
def read_config(config_file):
    config = configparser.ConfigParser()
    config.read(config_file)
    return config


# Fungsi untuk menyimpan konfigurasi ke file
def write_config(url, username, token, config_file):
    config = configparser.ConfigParser()
    config["Jenkins"] = {"url": url, "username": username, "token": token}
    with open(config_file, "w") as configfile:
        config.write(configfile)


@click.command()
@click.option(
    "--config", default="jenkins_config.ini", help="Path to the configuration file"
)
@click.option("--job-name", required=True, help="Regex pattern for the job name")
@click.option(
    "--folder-name", required=True, help="Name of the folder to move the job into"
)
def move_job(config, job_name, folder_name):
    """Move Jenkins jobs to a folder using regex."""

    # Baca konfigurasi dari file
    config_data = read_config(config)

    # Dapatkan nilai dari konfigurasi
    url = config_data.get("Jenkins", "url")
    username = config_data.get("Jenkins", "username")
    token = config_data.get("Jenkins", "token")

    # Jenkins API URL for getting job list
    get_jobs_url = f"{url}/api/json?tree=jobs[name]"

    # Jenkins API URL for creating a job in the folder
    create_job_url = f"{url}/job/{folder_name}/createItem?name={{job_name}}"

    # Jenkins authentication
    auth = (username, token)

    try:
        # Step 1: Get the list of jobs
        response = requests.get(get_jobs_url, auth=auth)
        response.raise_for_status()
        job_list = response.json()["jobs"]

        # Step 2: Move matching jobs to the specified folder
        for job in job_list:
            if re.match(job_name, job["name"]):
                # Get the existing job configuration
                get_job_url = f"{url}/job/{job['name']}/config.xml"
                response = requests.get(get_job_url, auth=auth)
                response.raise_for_status()
                job_config = response.text

                # Create the job in the specified folder
                response = requests.post(
                    create_job_url.format(job_name=job["name"]),
                    data=job_config,
                    auth=auth,
                    headers={"Content-Type": "application/xml"},
                )
                response.raise_for_status()

                click.echo(
                    f"Job '{job['name']}' moved to folder '{folder_name}' successfully."
                )

    except requests.exceptions.RequestException as e:
        click.echo(f"Failed to move jobs. {e}")


if __name__ == "__main__":
    move_job()
