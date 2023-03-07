#!/bin/bash

NORM=`tput sgr0`
BOLD=`tput bold`

cat <<EOF
┌─┐┬ ┬┌┐ ┌─┐┌─┐┌─┐┬ ┬┌┬┐
└─┐│ │├┴┐└─┐│  │ ││ │ │ 
└─┘└─┘└─┘└─┘└─┘└─┘└─┘ ┴ 
EOF

# Check requirements
if ! command -v docker &> /dev/null
then
    echo "docker could not be found."
    exit 1
fi

# Check help and args
function usage {
  echo -e \\n"Usage of subscout by cosad3s.${NORM}"\\n
  echo "${BOLD}-d${NORM}  Domain name to scout."
  echo -e "${BOLD}-h${NORM}  --Displays this help message. No further functions are performed."\\n
}

while getopts :hd: FLAG
do
  case $FLAG in
    d)
      DOMAIN=$OPTARG
      ;;
    h)  #show help
      usage
      exit 0
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option $OPTARG not allowed."
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Check arg
if [ -z "$DOMAIN" ]
then
    echo "No domain name supplied."
    usage
    exit 1
fi

# Check privileges
DOCKER_PRIV=$(docker ps)
if [ "$?" -ne 0 ]
then
    echo "It seems you have not the privilege to use Docker. Retry with 'root' user or through 'sudo ./subscout.sh $DOMAIN'."
    exit 1
fi

# Build
IMAGE_PRESENT=$(docker image inspect subscout)
if [ "$?" -ne 0 ]
then
    docker build --no-cache -t subscout ./image/
fi

# Check configuration
if [ ! -f "./config/api-keys.yaml" ]
then
    echo "File 'api-keys.yaml' is not present: will use 'api-keys-example.yaml' file."
    cp ./config/api-keys-example.yaml ./config/api-keys.yaml
fi

# Run
docker run -v $(pwd)/config/api-keys.yaml:/etc/theHarvester/api-keys.yaml -v $(pwd)/output:/app/results/final -it subscout "$DOMAIN"

exit 0