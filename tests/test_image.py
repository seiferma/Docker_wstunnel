from testcontainers.core.container import DockerContainer
from testcontainers.core.wait_strategies import LogMessageWaitStrategy
from testcontainers.core.network import Network

def test_help(img_name):
    with DockerContainer(img_name).with_command("-h") as subject:
        subject.waiting_for(LogMessageWaitStrategy(".*Usage: wstunnel .*"))

def test_simple_connection(img_name):
    with Network() as net:
        with DockerContainer(img_name).with_command("server ws://[::]:8000").with_exposed_ports(8000).with_network(net) as server:
            server_host = server.get_container_host_ip()
            server_port = server.get_exposed_port(8000)
            with DockerContainer(img_name).with_command(f"client -R tcp://12345:127.0.0.2:12345 ws://{server_host}:{server_port}").with_network(net) as client:
                server.waiting_for(LogMessageWaitStrategy(".*Starting wstunnel server listening on.*"))
                client.waiting_for(LogMessageWaitStrategy(".*Opening TCP connection to.*"))
                server.waiting_for(LogMessageWaitStrategy(".*Starting TCP server listening cnx on.*"))
