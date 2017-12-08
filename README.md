# litecoind
Litecoind with SSL support

## Deploy

### Generate SSL certs

    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout server.key -out server.crt
    
### Prepare config

    PASSWORD=`pwgen -nB 10 1`
    tee litecoin.conf << EOF
    onlynet=IPv4
    server=1
    rpcuser=rpcuser
    rpcpassword=$PASSWORD
    rpcport=9332
    rpcconnect=127.0.0.1
    disablewallet=0
    printtoconsole=1
    EOF

### Deploy using Docker
    
    mkdir litecoind-ssl data
    mv server.key litecoind-ssl/
    mv server.crt litecoind-ssl/
    docker run -d --restart=always --name=litecoind -v ./litecoin.conf:/etc/litecoind/litecoin.conf -v ./litecoind-ssl/:/etc/litecoind-ssl/ -v ./data/:/root/ kuberstack/litecoind

### Deploy using Kubernetes

    kubectl create secret generic litecoind-conf --from-file=litecoin.conf
    kubectl create secret generic litecoind-ssl --from-file=server.crt --from-file=server.key
    
    git clone https://github.com/kuberstack/litecoind
    $EDITOR litecoind/kubernetes/storage.yaml  # Change volume-ID
    kubectl create -f ./kubernetes/
