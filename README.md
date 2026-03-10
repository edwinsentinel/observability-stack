# Home Lab Infrastructure

This project sets up a complete home lab infrastructure using Vagrant and VirtualBox, consisting of multiple virtual machines running essential services for a distributed application stack.

## Architecture

The setup includes four virtual machines:

- **db01** (192.168.56.15): MySQL database server
- **mc01** (192.168.56.14): Memcached caching server
- **rmq01** (192.168.56.16): RabbitMQ message broker
- **app01** (192.168.56.12): Tomcat application server

## Prerequisites

Before running this setup, ensure you have the following installed:

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- Vagrant plugins:
  - `vagrant-hostmanager` (automatically manages /etc/hosts file)

## Installation

1. Clone or download this repository
2. Navigate to the project directory
3. Install required Vagrant plugins:
   ```bash
   vagrant plugin install vagrant-hostmanager
   ```
4. Start the virtual machines:
   ```bash
   vagrant up
   ```

## Usage

Once the VMs are running, you can:

- SSH into individual VMs: `vagrant ssh <vm-name>`
- Access services on their respective IPs
- View VM status: `vagrant status`
- Stop VMs: `vagrant halt`
- Destroy VMs: `vagrant destroy`

### SSH Access with MobaXterm

If you prefer to use MobaXterm for SSH access instead of the command line:

1. **Locate the SSH private key**:
   - The default Vagrant private key is located at: `C:\Users\<your-username>\.vagrant.d\insecure_private_key`
   - You can also find it by running: `vagrant ssh-config <vm-name>` in the project directory

2. **Configure MobaXterm session**:
   - Open MobaXterm and click "Session" → "SSH"
   - **Remote host**: Enter the VM IP address (see Services section below)
   - **Username**: `vagrant`
   - **Port**: `22`
   - **Use private key**: Check this box and browse to the private key file
   - Click "OK" to save the session

3. **Available VMs for SSH**:
   - **db01**: 192.168.56.15
   - **mc01**: 192.168.56.14
   - **rmq01**: 192.168.56.16
   - **app01**: 192.168.56.12

## Services

### MySQL (db01)
- **IP**: 192.168.56.15
- **Port**: 3306
- Default credentials: Check `mysql.sh` for setup details

### Memcached (mc01)
- **IP**: 192.168.56.14
- **Port**: 11211

### RabbitMQ (rmq01)
- **IP**: 192.168.56.16
- **Management UI**: http://192.168.56.16:15672
- Default credentials: guest/guest

### Tomcat (app01)
- **IP**: 192.168.56.12
- **Port**: 8080
- Application deployment directory: `/opt/tomcat/webapps`

## Configuration

- `Vagrantfile`: Main Vagrant configuration
- `application.properties`: Application configuration properties
- Shell scripts: Provisioning scripts for each service

## Networking

All VMs are connected via a private network (192.168.56.0/24). The hostmanager plugin automatically updates your local `/etc/hosts` file with VM hostnames.

## Troubleshooting

- If you encounter "Unknown configuration section 'hostmanager'" error, install the plugin: `vagrant plugin install vagrant-hostmanager`
- Ensure VirtualBox is properly installed and VT-x/AMD-V is enabled in BIOS
- Check VM status with `vagrant status` if provisioning fails

## Development

To modify the setup:

1. Edit the `Vagrantfile` for VM configuration changes
2. Modify shell scripts for provisioning changes
3. Run `vagrant provision` to apply changes to running VMs
4. Or `vagrant reload` to restart VMs with new configuration</content>
