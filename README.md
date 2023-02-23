# All Subdomains

## Usage

```bash
# Build
docker build -t allsubdomains .
# Run
docker run -v $(pwd)/api-keys.yaml:/etc/theHarvester/api-keys.yaml -v $(pwd)/output:/app/results/default -it allsubdomains example.org
```

## Configuration

Edit your api keys in `api-keys.yaml` file.
