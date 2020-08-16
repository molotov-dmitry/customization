#!/bin/bash

function packiso()
{
    iso_name="${config}-$1"
    iso_description="$2"

    if [[ -f "${iso_dir}/md5sum.txt" ]]
    then
        silent '' pushd "${iso_dir}"
        silent 'Calculating md5' bash -c 'find -type f ! -path ./md5sum.txt ! -path ./isolinux/isolinux.bin ! -path ./isolinux/boot.cat -exec md5sum {} \; > md5sum.txt'
        silent '' popd
    fi

    silent 'Making dir for iso' mkdir -p "${res_dir}"

    if [[ -e "${res_dir}/${iso_name}" ]]
    then
        silent 'Removing old iso' rm -f "${res_dir}/${iso_name}"
    fi

    if [[ -d "${iso_dir}/isolinux" ]]
    then
        silent 'Generating iso' genisoimage -o "${res_dir}/${iso_name}" \
            -b "isolinux/isolinux.bin" \
            -c "isolinux/boot.cat" \
            -p "Dmitry Sorokin" -V "${iso_description}" \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -cache-inodes -r -J -l \
            -x "${iso_dir}"/${livedir}/manifest.diff \
            -joliet-long \
            "${iso_dir}" || exit 1

        silent 'Making iso hybrid' isohybrid "${res_dir}/${iso_name}" || exit 1

    else
        silent 'Generating iso' genisoimage -o "${res_dir}/${iso_name}" \
            -f -v -J \
            "${iso_dir}" || exit 1
    fi

    if grep -sq "[ /]${iso_name}\$" "${res_dir}/MD5SUMS"
    then
        silent 'Removing old iso md5' sed -i "/[ /]${iso_name}\$/d" "${res_dir}/MD5SUMS"
    fi

    silent 'Generating md5 for iso' bash -c "md5sum \"${res_dir}/${iso_name}\" | sed 's/\/.*\///' >> \"${res_dir}/MD5SUMS\""

    if grep -sq "[ /]${iso_name}\$" "${res_dir}/REV"
    then
        silent 'Removing old iso revision' sed -i "/[ /]${iso_name}\$/d" "${res_dir}/REV"
    fi

    silent 'Generating revision for iso' bash -c "echo \"$(git log --pretty=format:'%h' | wc -w) $(git rev-parse --short HEAD) ${iso_name}\" >> \"${res_dir}/REV\""

    silent 'Changing rights for iso' chmod -R a+rw "${res_dir}"
}
