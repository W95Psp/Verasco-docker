docker run -d -p 223:22 -v $(echo ~)/Desktop/workdir:/root/workdir:Z verasco
sleep 3
sshpass -p hello ssh-copy-id root@localhost -p 223 