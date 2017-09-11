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
bash ./server.sh setup
```

The setup command will ask you to edit `/dev.properties`. The file looks like this:

```
app.server.address=YOUR_ADDRESS_HERE
```

Replace `YOUR_ADDRESS_HERE` with the public IP or DNS of the server. Leave off the `http://` and port.

After this, you should be ready to go.

### EC2 Setup
To install on a brand new Amazon EC2 Ubuntu 16.04 LTS instance, run the following in the terminal:

```sh
sudo apt-get update

# Install RVM
\curl -sSL https://get.rvm.io | bash
source /home/ubuntu/.rvm/scripts/rvm

# Install dependencies
rvm install 2.3.1
rvm --default use 2.3.1
gem install bundler
sudo apt-get install build-essential g++

# Set up server dependencies
cd /Statler
bundle install

# Do first-time setup
chmod +x ./server.sh
./server.sh setup
```

A file called `dev.properties` will be created in the Statler folder. Put your server's address in the field marked `YOUR_ADDRESS_HERE` (this address is the one labelled "Public DNS (IPv4)" in your EC2 console).

Finally, start the server:
```sh
# Start the server in the background (optional)
./server.sh start
```

The server should be up and running at this point.

### Usage

To start the server, run
```
bash ./server.sh start
```

To stop it, use `bash ./server.sh stop`.

The output from the latest session will be stored in `/server_log.txt`.

## API

See [API.md](/api.md) for information.

## Authors

* **Kendra Bird** - *VEMILab*
* **Brenden Peters** - *VEMILab*
* **Jonathan Cole** - *VEMILab* - [joncole.me](http://www.joncole.me)

## License

This project is licensed under the MIT License. Please see the [LICENSE.md](/LICENSE.md) file for details.