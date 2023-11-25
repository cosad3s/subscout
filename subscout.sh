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
  echo "${BOLD}-d${NORM}  Domain(s) to scout (separated by comma)."
  echo "${BOLD}-f${NORM}  Force subscout Docker image to be rebuilt."
  echo -e "${BOLD}-h${NORM}  --Displays this help message. No further functions are performed."\\n
}

while getopts :fhd: FLAG
do
  case $FLAG in
    d)
      DOMAIN=$OPTARG
      ;;
    f)
      FORCE_BUILD=1
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
    echo "It seems you have not the privilege to use Docker. Retry with 'root' user or through 'sudo ./subscout.sh -d $DOMAIN'."
    exit 1
fi

# Build
IMAGE_PRESENT=$(docker image inspect subscout)
if [ "$?" -ne 0 ] || [ -n "$FORCE_BUILD" ]
then
    echo "Will (re)build subscout Docker image ..."
    docker build --no-cache -t subscout ./image/
fi

# Check configurations
## Amass
if [ ! -f "./config/amass-config.ini" ]
then
    echo "File './config/amass-config.ini' is not present: will use './config/amass-config-example.ini' file."
    cp ./config/amass-config-example.ini ./config/amass-config.ini
fi
## Subfinder
if [ ! -f "./config/subfinder-config.yaml" ]
then
    echo "File './config/subfinder-config.yaml' is not present: will use './config/subfinder-config-example.yaml' file."
    cp ./config/subfinder-config-example.yaml ./config/subfinder-config.yaml
fi
## Fofax
if [ ! -f "./config/fofax-config.yaml" ]
then
    echo "File './config/fofax-config.yaml' is not present: will use './config/fofax-config-example.yaml' file."
    cp ./config/fofax-config-example.yaml ./config/fofax-config.yaml
fi

# Run
echo "Launching ..."
docker run -v $(pwd)/config/amass-config.ini:/etc/amass-config.ini -v $(pwd)/config/subfinder-config.yaml:/etc/subfinder-config.yaml -v $(pwd)/config/fofax-config.yaml:/root/.config/fofax/fofax.yaml -v $(pwd)/output:/app/results/final -it subscout "$DOMAIN"

exit 0