import argparse
import configparser
import re
import sys

import requests
from requests.auth import HTTPBasicAuth


def read_config(config_file):
    config = configparser.ConfigParser()
    config.read(config_file)
    return config["Credentials"]


# def add_job_to_folder(jenkins_url, username, api_token, folder_name, job_name_pattern):
#     # URL untuk mengambil konfigurasi folder
#     folder_url = f"{jenkins_url}/job/{folder_name}/config.xml"
#
#     # Ambil konfigurasi folder
#     response = requests.get(folder_url, auth=HTTPBasicAuth(username, api_token))
#     folder_config = response.text
#
#     # Tambahkan pekerjaan ke dalam konfigurasi folder
#     job_line = f"<name>{job_name_pattern}</name>"
#     if not re.search(f"<name>{job_name_pattern}</name>", folder_config):
#         folder_config = folder_config.replace("</items>", f"  {job_line}\n</items>")
#
#         # Update konfigurasi folder
#         response = requests.post(
#             folder_url,
#             auth=HTTPBasicAuth(username, api_token),
#             headers={"Content-Type": "application/xml"},
#             data=folder_config,
#         )
#
#         if response.status_code == 200:
#             print(
#                 f"Pekerjaan dengan pola nama {job_name_pattern} berhasil ditambahkan ke dalam folder {folder_name}"
#             )
#         else:
#             print(f"Gagal menambahkan pekerjaan. Kode status: {response.status_code}")
#     else:
#         print(
#             f"Pekerjaan dengan pola nama {job_name_pattern} sudah ada dalam folder {folder_name}"
#         )


def move_existing_job_to_folder(
    jenkins_url, username, api_token, folder_name, existing_job_name
):
    # URL untuk mengambil konfigurasi folder
    folder_url = f"{jenkins_url}/job/{folder_name}/config.xml"

    # Ambil konfigurasi folder
    response = requests.get(folder_url, auth=HTTPBasicAuth(username, api_token))
    folder_config = response.text

    # Buat URL untuk pekerjaan yang sudah ada
    existing_job_url = f"{jenkins_url}/job/{existing_job_name}"

    # Tambahkan pekerjaan ke dalam konfigurasi folder
    job_line = f"<name>{existing_job_name}</name>"
    if not re.search(f"<name>{existing_job_name}</name>", folder_config):
        folder_config = folder_config.replace("</items>", f"  {job_line}\n</items>")

        # Update konfigurasi folder
        response = requests.post(
            folder_url,
            auth=HTTPBasicAuth(username, api_token),
            headers={"Content-Type": "application/xml"},
            data=folder_config,
        )

        if response.status_code == 200:
            print(
                f"Pekerjaan {existing_job_name} berhasil dipindahkan ke dalam folder {folder_name}"
            )
        else:
            print(f"Gagal memindahkan pekerjaan. Kode status: {response.status_code}")
    else:
        print(f"Pekerjaan {existing_job_name} sudah ada dalam folder {folder_name}")


def add_job_to_view(jenkins_url, username, api_token, view_name, job_name):
    # URL untuk mengambil konfigurasi view
    view_url = f"{jenkins_url}/view/{view_name}/config.xml"

    # Ambil konfigurasi view
    response = requests.get(view_url, auth=HTTPBasicAuth(username, api_token))
    view_config = response.text

    # Tambahkan pekerjaan ke dalam konfigurasi view
    job_line = f"<string>{job_name}</string>"
    if job_line not in view_config:
        view_config = view_config.replace("</jobNames>", f"  {job_line}\n</jobNames>")

        # Update konfigurasi view
        response = requests.post(
            view_url,
            auth=HTTPBasicAuth(username, api_token),
            headers={"Content-Type": "application/xml"},
            data=view_config,
        )

        if response.status_code == 200:
            print(
                f"Pekerjaan {job_name} berhasil ditambahkan ke dalam view {view_name}"
            )
        else:
            print(f"Gagal menambahkan pekerjaan. Kode status: {response.status_code}")
    else:
        print(f"Pekerjaan {job_name} sudah ada dalam view {view_name}")


def remove_job_from_view(jenkins_url, username, api_token, view_name, job_name):
    # URL untuk mengambil konfigurasi view
    view_url = f"{jenkins_url}/view/{view_name}/config.xml"

    # Ambil konfigurasi view
    response = requests.get(view_url, auth=HTTPBasicAuth(username, api_token))
    view_config = response.text

    # Hapus pekerjaan dari konfigurasi view
    job_line = f"<string>{job_name}</string>"
    if job_line in view_config:
        view_config = view_config.replace(f"  {job_line}\n", "")

        # Update konfigurasi view
        response = requests.post(
            view_url,
            auth=HTTPBasicAuth(username, api_token),
            headers={"Content-Type": "application/xml"},
            data=view_config,
        )

        if response.status_code == 200:
            print(f"Pekerjaan {job_name} berhasil dihapus dari view {view_name}")
        else:
            print(f"Gagal menghapus pekerjaan. Kode status: {response.status_code}")
    else:
        print(f"Pekerjaan {job_name} tidak ditemukan dalam view {view_name}")


def create_view(jenkins_url, username, api_token, view_name):
    # URL untuk membuat view baru
    create_view_url = f"{jenkins_url}/createView?name={view_name}"

    # Kirim permintaan untuk membuat view
    response = requests.post(create_view_url, auth=HTTPBasicAuth(username, api_token))

    if response.status_code == 200:
        print(f"view {view_name} berhasil dibuat")
    else:
        print(f"Gagal membuat view. Kode status: {response.status_code}")


def delete_view(jenkins_url, username, api_token, view_name):
    # URL untuk menghapus view
    delete_view_url = f"{jenkins_url}/view/{view_name}/doDelete"

    # Kirim permintaan untuk menghapus view
    response = requests.post(delete_view_url, auth=HTTPBasicAuth(username, api_token))

    if response.status_code == 200:
        print(f"view {view_name} berhasil dihapus")
    else:
        print(f"Gagal menghapus view. Kode status: {response.status_code}")


def list_views(credentials):
    # Mendapatkan daftar view dari Jenkins
    url = f"{credentials['JENKINS_URL']}/api/json"
    response = requests.get(
        url, auth=HTTPBasicAuth(credentials["USERNAME"], credentials["API_TOKEN"])
    )

    # if response.status_code == 200:
    #     data = response.json()
    #     views = [view["name"] for view in data["views"]]
    #     print(f"Existing views in Jenkins:\n{', '.join(views)}")
    # else:
    #     print(f"Failed to retrieve views. Status code: {response.status_code}")

    if response.status_code == 200:
        data = response.json()
        views = [view["name"] for view in data["views"]]
        return views
    else:
        print(f"Failed to retrieve views. Status code: {response.status_code}")
        return []


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Manajemen view Jenkins.")
    parser.add_argument(
        "--config-file",
        "-c",
        default="config.ini",
        help="Nama file konfigurasi (default: config.ini)",
    )

    subparsers = parser.add_subparsers(
        title="commands", dest="command", help="Pilih salah satu perintah"
    )

    # # Perintah untuk menambahkan pekerjaan ke dalam folder
    # add_to_folder_parser = subparsers.add_parser(
    #     "addtofolder", help="Tambahkan pekerjaan ke dalam folder"
    # )
    # add_to_folder_parser.add_argument(
    #     "--folder-name", "-f", required=True, help="Nama folder Jenkins"
    # )
    # add_to_folder_parser.add_argument(
    #     "--job-name-pattern",
    #     "-jp",
    #     required=True,
    #     help="Pola regex untuk nama pekerjaan Jenkins",
    # )

    # Perintah untuk memindahkan pekerjaan yang sudah ada ke dalam folder
    move_existing_parser = subparsers.add_parser(
        "moveexisting", help="Pindahkan pekerjaan yang sudah ada ke dalam folder"
    )
    move_existing_parser.add_argument(
        "--folder-name", "-f", required=True, help="Nama folder Jenkins"
    )
    move_existing_parser.add_argument(
        "--existing-job-name",
        "-ej",
        required=True,
        help="Nama pekerjaan Jenkins yang sudah ada",
    )

    # Perintah untuk menambahkan pekerjaan ke view
    add_parser = subparsers.add_parser("add", help="Tambahkan pekerjaan ke dalam view")
    add_parser.add_argument(
        "--view-name", "-v", required=True, help="Nama view Jenkins"
    )
    add_parser.add_argument(
        "--job-name", "-j", required=True, help="Nama pekerjaan Jenkins"
    )

    # Perintah untuk menghapus pekerjaan dari view
    remove_parser = subparsers.add_parser("remove", help="Hapus pekerjaan dari view")
    remove_parser.add_argument(
        "--view-name", "-v", required=True, help="Nama view Jenkins"
    )
    remove_parser.add_argument(
        "--job-name", "-j", required=True, help="Nama pekerjaan Jenkins"
    )

    # Perintah untuk membuat view baru
    create_parser = subparsers.add_parser("create", help="Buat view baru")
    create_parser.add_argument(
        "--view-name", "-v", required=True, help="Nama view Jenkins"
    )

    # Perintah untuk menghapus view
    delete_parser = subparsers.add_parser("delete", help="Hapus view")
    delete_parser.add_argument(
        "--view-name", "-v", required=True, help="Nama view Jenkins"
    )

    list_parser = subparsers.add_parser("list", help="Tampilkan daftar view yang ada")

    args = parser.parse_args()

    if len(sys.argv) == 1:
        # Jika tidak ada argumen (hanya nama skrip), tampilkan pesan bantuan.
        parser.print_help()
        sys.exit(0)

    try:
        args = parser.parse_args()
    except SystemExit:
        # Jika ada SystemExit exception (biasanya terjadi ketika --help digunakan),
        # tampilkan pesan bantuan dan keluar dengan aman.
        parser.print_help()
        sys.exit(0)

    # Baca informasi dari file konfigurasi
    credentials = read_config(args.config_file)

    # Tangani perintah yang dipilih
    if args.command == "add":
        add_job_to_view(
            credentials["JENKINS_URL"],
            credentials["USERNAME"],
            credentials["API_TOKEN"],
            args.view_name,
            args.job_name,
        )
    # elif args.command == "addtofolder":
    #     add_job_to_folder(
    #         credentials["JENKINS_URL"],
    #         credentials["USERNAME"],
    #         credentials["API_TOKEN"],
    #         args.folder_name,
    #         args.job_name_pattern,
    #     )
    elif args.command == "moveexisting":
        move_existing_job_to_folder(
            credentials["JENKINS_URL"],
            credentials["USERNAME"],
            credentials["API_TOKEN"],
            args.folder_name,
            args.existing_job_name,
        )
    elif args.command == "remove":
        remove_job_from_view(
            credentials["JENKINS_URL"],
            credentials["USERNAME"],
            credentials["API_TOKEN"],
            args.view_name,
            args.job_name,
        )
    elif args.command == "create":
        create_view(
            credentials["JENKINS_URL"],
            credentials["USERNAME"],
            credentials["API_TOKEN"],
            args.view_name,
        )
    elif args.command == "delete":
        delete_view(
            credentials["JENKINS_URL"],
            credentials["USERNAME"],
            credentials["API_TOKEN"],
            args.view_name,
        )
    elif args.command == "list":
        print("Available Jenkins Views:")
        views = list_views(credentials)

        if not views:
            print("Tidak dapat menampilkan daftar view.")
        else:
            print("\n".join(views))
    else:
        print("Pilih salah satu perintah: list, add, remove, create, atau delete")
