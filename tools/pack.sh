#!/bin/bash

function packiso()
{
    local iso_old_name="$1"
    local iso_description="$2"
    local iso_src="$3"

    local iso_extension="${iso_old_name##*.}"
    local iso_filename="${iso_old_name%.*}"

    local iso_name="${iso_filename}-${config}.${iso_extension}"

    ### Calculate files hash ===================================================

    silent '' pushd "${iso_dir}"
    silent 'Calculating md5' bash -c 'find -type f ! -path ./md5sum.txt ! -path ./isolinux/isolinux.bin ! -path ./isolinux/boot.cat -exec md5sum {} \; > md5sum.txt'
    silent '' popd

    ### Remove old iso image ===================================================

    mkdir -p "${res_dir}"
    rm -f "${res_dir}/${iso_name}"

    ### Set options ============================================================

    local -a iso_options

    ### mkisofs options --------------------------------------------------------

    iso_options+=('-R' '-r')                            # Sets ownership and permissions of the files in the ISO
    iso_options+=('-J' '-joliet-long')                  # Enables production of a Joliet tree for use on systems by Microsoft Inc

    iso_options+=('-l')                                 # Allow full 31-character filenames
    iso_options+=('-cache-inodes')                      # Cache inode and device numbers to find hard links to files
    iso_options+=("-allow-multidot")                    # Allows more than one dot to appear filenames

    iso_options+=('-iso-level' '3')                     # Set the iso9660 conformance level

    ### xorriso boot options ---------------------------------------------------

    if [[ -f '/usr/lib/ISOLINUX/isohdpfx.bin' && -d "${iso_dir}/isolinux" ]]
    then
        iso_options+=('-isohybrid-mbr')
        iso_options+=('/usr/lib/ISOLINUX/isohdpfx.bin') # Set SYSLINUX mbr/isohdp[fp]x*.bin for isohybrid
        iso_options+=('-partition_offset' '16')             # Make image mountable by first partition, too
    fi

    ### Common options ---------------------------------------------------------

    iso_options+=("-V" "${iso_description}")            # Sets the filesystem's name
    iso_options+=("-p" "Dmitry Sorokin")                # Sets the author's name

    iso_options+=("-o" "${res_dir}/${iso_name}")        # Sets the name of the new ISO image file

    ### mkisofs boot options ---------------------------------------------------

    if [[ -d "${iso_dir}/isolinux" ]]
    then
        iso_options+=("-b" "isolinux/isolinux.bin")     # Boot image to be used when making an El Torito bootable CD for x86 PCs
        iso_options+=("-c" "isolinux/boot.cat")         # Specifies the path and filename of the boot catalog
        iso_options+=('-no-emul-boot')                  # The system will load and execute this image without performing any disk emulation.
        iso_options+=('-boot-load-size' '4')            # Specifies the number of "virtual" (512-byte) sectors to load in no-emulation mode
        iso_options+=('-boot-info-table')               # Specifies that a 56-byte table with information of the CD-ROM layout will be patched in at offset 8 in the boot file.
        iso_options+=('-isohybrid-gpt-basdat')          #
        iso_options+=('-isohybrid-apm-hfsplus')         #
    fi

    ### Generate iso ===========================================================

    silent 'Generating iso' xorriso -as mkisofs "${iso_options[@]}" "${iso_dir}" || exit 1

    if [[ -d "${iso_dir}/isolinux" ]]
    then
        silent 'Making iso hybrid' isohybrid "${res_dir}/${iso_name}" || exit 1
    fi

    silent 'Changing rights for iso' chmod -R a+rw "${res_dir}"

    ### Update MD5 hash for all custom iso images ==============================

    sed -i "/[ /]${iso_name}\$/d" "${res_dir}/MD5SUMS" 2>/dev/null
    md5sum "${res_dir}/${iso_name}" | sed 's/\/.*\///' >> "${res_dir}/MD5SUMS"

    for iso in $(cut -d ' ' -f 3 "${res_dir}/MD5SUMS" | sort -u)
    do
        if [[ ! -f "${res_dir}/${iso}" ]]
        then
            sed -i "/[ /]${iso}\$/d" "${res_dir}/MD5SUMS" 2>/dev/null
        fi
    done

    ### ========================================================================
}
