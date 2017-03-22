# Statler

![Media Ecology Project Image](/media/mep-banner.png)

Statler is a server app for storing and retrieving rich annotations for video, created for the [Media Ecology Project](https://sites.dartmouth.edu/mediaecology/). It is a companion to [Waldorf](https://github.com/seieibob/Waldorf), which serves as the frontend.

## Setup

### Prerequisites

* Ruby 2.3.1 (and Bundler gem)
* Ubuntu 16.04 LTS

### Installation

Unpack this repo somewhere, cd into it, and then run the following:

```
bundle install
bash ./start_server.sh
```

Starting the server will fail the first time, and ask you to edit `/dev.properties`. The file looks like this:

```
app.server.address=YOUR_ADDRESS_HERE
```

Replace `YOUR_ADDRESS_HERE` with the public IP or DNS of the server. Leave off the `http://` and port.

After this, you should be ready to go.

### Usage

To start the server, run
```
bash ./start_server.sh
```

To stop it, use `/stop_server.sh`.

The output from the latest session will be stored in `/server_log.txt`.

## Using the Server

API information is forthcoming.

## EC2 Setup
To install on a brand new Amazon EC2 Ubuntu 16.04 LTS instance, do the following:
```
# Install dependencies
rvm install 2.3.1
rvm --default use 2.3.1
gem install bundler
sudo apt-get install build-essential g++

# Set up server
cd /Statler
bundle install

# Do first-time setup
bash ./start_server.sh

# Set up the dev.properties file!

# Start the server in the background (optional)
bash ./start_server.sh
```

## Authors

* **Kendra Bird** - *VEMILab*
* **Brenden Peters** - *VEMILab*

## License

This project is licensed under the MIT License. Please see the [LICENSE.md](/LICENSE.md) file for details.