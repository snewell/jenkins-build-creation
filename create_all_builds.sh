#!/bin/sh

usage() {
	echo "${0} <jenkins-url> <username> <authentication-token> <name> <git url> <git branch>"
}

get_crumb() {
	user=${1}
	auth_token=${2}
	jenkins_url=${3}

	# curl command pilfered from cloudbees: https://support.cloudbees.com/hc/en-us/articles/219257077-CSRF-Protection-Explained
	curl -u "${1}:${2}" "${jenkins_url}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" 2>/dev/null
}

make_folder() {
	user=${1}
	auth_token=${2}
	jenkins_url=${3}
	crumb=${4}
	folder_name=${5}

	# modified from this example: https://gist.github.com/stuart-warren/7786892
	curl -XPOST "${jenkins_url}/createItem?name=${folder_name}&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22${folder_name}%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK" \
	    --user "${user}:${auth_token}" \
	    --header "Content-Type:application/x-www-form-urlencoded" \
	    --header "${crumb}" 2>/dev/null
}

make_job() {
	user=${1}
	auth_token=${2}
	jenkins_url=${3}
	crumb=${4}
	folder_name=${5}
	job_name=${6}

	# modified from this example: https://gist.github.com/stuart-warren/7786892
	curl -s -XPOST "${jenkins_url}/job/${folder_name}/createItem?name=${job_name}" \
	    --data-binary @- \
	    --user "${user}:${auth_token}" \
	    --header "Content-Type:text/xml" \
	    --header "${crumb}" 2>/dev/null
}

make_jobs() {
	user=${1}
	auth_token=${2}
	jenkins_url=${3}
	crumb=${4}
	folder_name=${5}

	success=0
	failed=0
	find "$(dirname ${0})/build-configs" -name '*.xml' |
	while read config_file; do
		job_name=$(basename "${config_file}" | cut '-d.' -f 1)
		result=$(sed -e "s^GIT_URL^${git_url}^g" \
		             -e "s^GIT_BRANCH^${git_branch}^g" "${config_file}" |
		         make_job "${user}" "${auth_token}" "${jenkins_url}" "${crumb}" "${name}" "${job_name}")
		if [ $(echo "${result}" | wc -l) -eq 1 ]; then
			success=$((${success} + 1))
		else
			failed=$((${failed} + 1))
			echo -e "Failed to create ${folder_name}/${job_name}\n${result}"
		fi
	done

	if [ ${failed} -eq 0 ]; then
		# great, everything worked!
		exit 0
	else
		if [ ${success} -gt 0 ]; then
			# some jobs created
			exit 2
		else
			# everything failed
			exit 3
		fi
	fi
}

if [ ${#} -eq 6 ]; then
	jenkins_url=${1}
	user=${2}
	auth_token=${3}
	name=${4}
	git_url=${5}
	git_branch=${6}

	crumb=$(get_crumb "${user}" "${auth_token}" "${jenkins_url}")
	if [ $(echo "${crumb}" | wc -l) -eq 1 ]; then
		# the crumb should be one line, so if we got more something bad happened
		result=$(make_folder "${user}" "${auth_token}" "${jenkins_url}" "${crumb}" "${name}")
		if [ $(echo "${result}" | wc -l) -eq 1 ]; then
			# folder's been created, so make all the jobs
			make_jobs "${user}" "${auth_token}" "${jenkins_url}" "${crumb}" "${name}"
		else
			echo -e "Failed to create project folder\n${result}" >&2
			exit 1
		fi
	else
		echo -e "Failed to get crumb:\n${crumb}" >&2
		exit 1
	fi
elif [ ${#} -eq 0 ]; then
	usage
else
	echo "Invalid usage" >&2
	usage >&2
	exit 1
fi
