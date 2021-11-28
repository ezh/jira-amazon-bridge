import os

import requests
from requests.auth import HTTPBasicAuth

atlassian_host = os.environ['ATLASSIAN_HOST']
atlassian_user = os.environ['ATLASSIAN_USER']
atlassian_password = os.environ['ATLASSIAN_PASSWORD']

MAX_RESULTS = 50


def jira_get(url, params):
    return requests.get(
        url,
        auth=HTTPBasicAuth(atlassian_user, atlassian_password),
        headers={'Accept': 'application/json'},
        params=params,
    )


def jira_num_results(url):
    """Return the number of total results."""
    params = {'maxResults': 0}
    response = jira_json_data_for_url(url, params)
    return response.get('total', 1)


def jira_json_data_for_url(url, params):
    """Return JSON data for a given url and its parameters."""
    return jira_get(url=url, params=params).json()


def jira_paginated_json_data(url, key='values', extra_params={}):
    num_results = jira_num_results(url=url)
    result_list = []
    params = {
        'maxResults': MAX_RESULTS,
        'startAt': 0,
    }
    params = params | extra_params
    for start in range(0, num_results, MAX_RESULTS):
        params.update(
            {
                'startAt': start,
            }
        )
        response = jira_json_data_for_url(url=url, params=params)
        result_list.extend(response[key])
    return result_list


def jira_all_projects_as_a_list():
    """
    Returns:
      list: All users found in jira.
    """
    return jira_paginated_json_data(f'{atlassian_host}/rest/api/3/project/search')


def jira_all_issues_as_a_list(project_key):
    return jira_paginated_json_data(
        f'{atlassian_host}/rest/api/3/search',
        'issues',
        {'jql': f'project={project_key}'},
    )


def jira_all_workloads_as_a_list(issue_id, issue):
    workloads = jira_paginated_json_data(
        f'{atlassian_host}/rest/api/3/issue/{issue_id}/worklog', 'worklogs'
    )
    for workload in workloads:
        workload['key'] = issue['key']
        workload['fields'] = {
            'project': issue['fields']['project']
        }
        workload['timeSpentMinutes'] = workload['timeSpentSeconds'] / 60
        workload['timeSpentHours'] = workload['timeSpentMinutes'] / 60
    return workloads
