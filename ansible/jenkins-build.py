import argparse

import requests
import yaml


def read_config(config_file):
    try:
        with open(config_file, "r") as f:
            config = yaml.safe_load(f)
        return config["jenkins"]
    except Exception as e:
        print(f"Gagal membaca konfigurasi: {str(e)}")
        return None


def run_jenkins_job(job_name, parameters, config):
    build_url = f"{config['url']}job/{job_name}/buildWithParameters"

    # Parameter untuk disertakan dalam permintaan POST
    data = {}
    for param_name, param_value in parameters.items():
        data[param_name] = param_value

    auth = (config["username"], config["token"])

    try:
        # Mengirim permintaan POST untuk memulai build dengan parameter
        response = requests.post(build_url, data=data, auth=auth)

        if response.status_code == 201:
            print(f"Build job {job_name} berhasil dimulai.")
        else:
            print(
                f"Gagal memulai build job {job_name}. Status code: {response.status_code}"
            )
            print(response.text)
    except Exception as e:
        print(f"Terjadi kesalahan: {str(e)}")


def main():
    parser = argparse.ArgumentParser(description="Jenkins Job Runner CLI")
    parser.add_argument(
        "-c", "--config", help="Nama file konfigurasi (default: jenkins_config.yaml)"
    )
    parser.add_argument("-j", "--job", help="Nama job Jenkins yang akan dijalankan")
    parser.add_argument(
        "-p",
        "--parameter",
        action="append",
        metavar="PARAM=VALUE",
        help="Parameter Jenkins (bisa digunakan lebih dari sekali)",
    )

    args = parser.parse_args()

    config_file = args.config or "jenkins_config.yaml"
    config = read_config(config_file)

    if not config:
        return

    job_name = args.job or config.get("default_job", None)

    if not job_name:
        print("Nama job harus disediakan melalui argumen atau dalam file konfigurasi.")
        return

    parameters = {}
    if args.parameter:
        for param in args.parameter:
            param_name, param_value = param.split("=")
            # Menambahkan karakter escape (\) sebelum dollar ($) dalam nilai parameter
            param_value = param_value.replace("$", r"\$")
            parameters[param_name] = param_value

    run_jenkins_job(job_name, parameters, config)


if __name__ == "__main__":
    main()
