#!/bin/bash

function packiso()
{
    local iso_old_name="$1"
    local iso_description="$2"
    local iso_src="$3"

    local iso_extension="${iso_old_name##*.}"
    local iso_filename="${iso_old_name%.*}"

    local iso_name="${iso_filename}-${config}.${iso_extension}"

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

    local make_hybrid=0

    local -a iso_options

    iso_options+=("-r")                                 # Sets ownership and permissions of the files in the ISO
    iso_options+=("-V" "${iso_description}")            # Sets the filesystem's name
    iso_options+=("-p" "Dmitry Sorokin")                # Sets the author's name
    iso_options+=("-o" "${res_dir}/${iso_name}")        # Sets the name of the new ISO image file
    iso_options+=("-J" "-joliet-long")             # Enables production of a Joliet tree for use on systems by Microsoft Inc
    iso_options+=("-cache-inodes")                      # Ignored
    iso_options+=("-allow-multidot")                    # Allows more than one dot to appear filenames
    iso_options+=("-l")                                 # Allow full 31-character filenames


    if [[ -n "${iso_src}" ]]
    then
        iso_options+=( $(xorriso -indev "${iso_src}" -report_el_torito as_mkisofs 2>/dev/null | grep '^-c \|^-b \|^-no-emul-boot$\|^-boot-load-size \|^-boot-info-table$\|^-no-emul-boot$\|^-boot-load-size ' | sed "s/ '/ /;s/'$//;s/^-e /--eltorito-boot /;s/ \// /") )
        make_hybrid=0
    elif [[ -d "${iso_dir}/isolinux" ]]
    then
        iso_options+=("-b" "isolinux/isolinux.bin")     # Boot image to be used when making an El Torito bootable CD for x86 PCs
        iso_options+=("-c" "isolinux/boot.cat")         # Specifies the path and filename of the boot catalog
        iso_options+=("-no-emul-boot")                  # The system will load and execute this image without performing any disk emulation.
        iso_options+=("-boot-load-size" "4")            # Specifies the number of "virtual" (512-byte) sectors to load in no-emulation mode
        iso_options+=("-boot-info-table")               # Specifies that a 56-byte table with information of the CD-ROM layout will be patched in at offset 8 in the boot file.

        make_hybrid=1
    fi

    silent 'Generating iso' genisoimage "${iso_options[@]}" "${iso_dir}" || exit 1

    if [[ $make_hybrid -eq 1 ]]
    then
        silent 'Making iso hybrid' isohybrid "${res_dir}/${iso_name}" || exit 1
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
