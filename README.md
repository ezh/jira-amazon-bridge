# Atlassian JIRA -> Amazon OpenSearch bridge

## Install

Go to `terraform/prod` and run `terraform apply`

## Development

### AWS lambda

* Install the specific version of python

```
asdf install
```

* Create and activate virtual environment

```
asdf env python python -mvenv .venv
source .venv/bin/activate
```

* Install dependencies

```
pip install poetry
cd python && poetry install
```

# Requirements

* Python 3.9
* Terraform 1.0
