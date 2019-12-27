#!/bin/sh -lexu

exit_with_message()
{
    echo $1 >&2
    exit 1
}

echo "${INPUT_GCLOUD_AUTH_KEY}" | docker login "https://${INPUT_HOSTNAME}" -u _json_key --password-stdin

git_ref_prefix=$(echo ${GITHUB_REF} | cut -d '/' -f 1)
git_ref_type=$(echo ${GITHUB_REF} | cut -d '/' -f 2)
git_ref_name=$(echo ${GITHUB_REF} | cut -d '/' -f 3-)
if [ ! "${git_ref_prefix}" = "refs" ] || [ -z "${git_ref_type}" ] || [ -z "${git_ref_name}" ]
then
    exit_with_message "Invalid \$GITHUB_REF: ${GITHUB_REF}"
fi

latest=false
case ${git_ref_type} in
    heads)
        image_version_prefix="b"
        if [ "${git_ref_name}" = "master" ]
        then
            latest=true
        fi
        ;;
    tags)
        image_version_prefix="t"
        ;;
    *)
        exit_with_message "Invalid \$git_ref_type: ${git_ref_type}"
esac

image_repository="${INPUT_HOSTNAME}/${INPUT_GCLOUD_PROJECT_ID}/${INPUT_IMAGE_NAME}"
image_version="${image_version_prefix}--${git_ref_name/\//--}"
image_build_tag="${image_repository}:${image_version}"

echo ::set-output name=image_repository::${image_repository}
echo ::set-output name=image_version::${image_version}

docker pull ${image_build_tag} || true
docker build . --cache-from ${image_build_tag} -t ${image_build_tag}
docker push ${image_build_tag}

docker tag ${image_build_tag} ${image_repository}:${GITHUB_SHA}
docker push ${image_repository}:${GITHUB_SHA}

if $latest
then
    docker tag ${image_build_tag} ${image_repository}:latest
    docker push ${image_repository}:latest
fi
