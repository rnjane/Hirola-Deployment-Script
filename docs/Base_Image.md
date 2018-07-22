## Tech Stack Used

This read me was made using **Packer Version 1.1.3**.
The commands below are run on **MacOs Version 10.12.6** on **Darwin** platform.
If using a different platform find the alternative for any commands below.

## How to Create the Base image when moving to a new GCP Project.

To create the base image follow the steps below: -


### Step 1

* Well you first have to ensure that you have cloned the repo on which the packer scripts are. 


* To do that on you terminal run the command: `git clone https://github.com/JamesKirkAndSpock/Hirola-Deployment-Script.git`

### Step 2

* Once done, you need to change directory into the cloned repo. `cd Hirola-Deployment-Script`

* Create a folder called **'account-folder'** once you have changed directory and change directory into it. `mkdir account-folder && cd account-folder`

* Create a file called **'account.json'** after running the command above.

* In that file copy and paste the google cloud platform service account key. On this step you might have to follow this links to be able to:
    * [create a service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
    * [create a service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)
    * [grant roles to the service account key](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts). Roles to be given are at least admin capabilities of Compute Image User, Compute Instance Admin and Service Account Actor.


* Download the key and paste it in the account.json file.


### Step 3

* Change directory to the **'hirola-base-image'** folder.
`cd .. && cd hirola-base-image`

* Give the Google cloud Project Id as an environment variable. `export PROJECT_ID=<replace this with your google cloud project id>`

* Validate the packer file that it is ready to run. `packer validate packer.json`

* Build the packer image. `packer build packer.json`








