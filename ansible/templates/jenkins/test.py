import argparse
import configparser
import re  # Import the 're' module

import jenkins


def move_job_to_folder(server, folder_name, job_name):
    try:
        server.move_job(job_name, folder_name)
        print(f"Job '{job_name}' berhasil dipindahkan ke dalam folder '{folder_name}'")
    except jenkins.JenkinsException as e:
        print(
            f"Gagal memindahkan job '{job_name}' ke dalam folder '{folder_name}': {e}"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Memindahkan job Jenkins ke dalam folder"
    )
    parser.add_argument(
        "--config", required=True, help="Path ke file konfigurasi (.ini)"
    )
    parser.add_argument(
        "--folder", required=True, help="Nama folder tempat pekerjaan akan dipindahkan"
    )
    parser.add_argument(
        "--regex",
        required=True,
        help="Regex pattern untuk memilih job yang akan dipindahkan",
    )

    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read(args.config)

    url = config.get("jenkins", "url")
    username = config.get("jenkins", "username")
    token = config.get("jenkins", "token")

    server = jenkins.Jenkins(url, username=username, password=token)

    try:
        folder_info = server.get_job_info(args.folder)
        if folder_info is None:
            print(f"ERROR: Folder '{args.folder}' not found")
            return
    except jenkins.JenkinsException as e:
        print(f"ERROR: {e}")
        return

    # Use re.match for regex matching on job names
    main_folder_jobs = [
        job["name"] for job in server.get_jobs() if re.match(args.regex, job["name"])
    ]
    print(f"Searching main folder: {main_folder_jobs}")

    subfolders = [item["name"] for item in server.get_all_jobs()]
    for subfolder_name in subfolders:
        if subfolder_name != args.folder:
            print(f"Searching folder '{subfolder_name}'")
            try:
                subfolder_jobs = [
                    job["name"]
                    for job in server.get_jobs(view_name=subfolder_name)
                    if re.match(args.regex, job["name"])
                ]
                main_folder_jobs.extend(subfolder_jobs)
                print(f"Found {subfolder_jobs}")
            except jenkins.JenkinsException as e:
                print(f"ERROR: {e}")

    # Move them
    for job_name in main_folder_jobs:
        move_job_to_folder(server, args.folder, job_name)


if __name__ == "__main__":
    main()
