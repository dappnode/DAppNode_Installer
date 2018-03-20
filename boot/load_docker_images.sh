docker load -i ./dappnode/dappnode_all_docker_images.tar.xz
docker-compose -f ./dappnode/DNCORE/docker-compose.yml up -d
rm -f /etc/cron.d/dappnode_cron_task
