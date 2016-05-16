#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

sudo echo -n

clear
clear

### Applications ===============================================================

## Adding PPA`s ----------------------------------------------------------------

#ppaadd  'Ubuntu Make'               'ubuntu-desktop'            'ubuntu-make'

## Updating --------------------------------------------------------------------

appupdate
#appupgrade

## Install ---------------------------------------------------------------------

appinstall 'Build tools'            'build-essential astyle unifdef'
appinstall 'Multilib tools'         'gcc-multilib g++-multilib'
appinstall 'Static analysis tools'  'cppcheck cppcheck-gui'
appinstall 'Dynamic analysis tools' 'valgrind'

appinstall 'X11 sdk'                'libx11-dev'

appinstall 'OpenGL sdk'             'freeglut3 freeglut3-dev libglew1.10 libglew-dbg libglu1-mesa libglu1-mesa-dev libgl1-mesa-glx libgl1-mesa-dev'

appinstall 'Qt SDK'                 'qml qtbase5-dev qtdeclarative5-dev qt5-doc'
appinstall 'Qt Libs'                'libqt5svg5 libqt5webkit5-dev'
appinstall 'Qt IDE'                 'qtcreator'

appinstall 'GTK+ SDK'               'libgtk-3-dev libgtkmm-3.0-dev libtool libtool-bin'
appinstall 'GTK+ Libs'              'libgtksourceview-3.0-dev libgtksourceview-3.0-1 libgtksourceviewmm-3.0-0v5 libgtksourceview-3.0-dev libpeas-1.0-0 libpeas-dev libgit2-glib-1.0-dev libgit2-glib-1.0-0'
appinstall 'GTK+ IDE'               'anjuta glade'

appinstall 'GNOME IDE'              'gnome-builder'

appinstall 'Doxygen'                'doxygen graphviz'

appinstall 'Postgres'               'postgresql pgadmin3 libpq5 libpq-dev'
appinstall 'SQLite'                 'sqlite sqliteman libsqlite3-0 libsqlite3-dev'

#appinstall 'Ubuntu Make'            'ubuntu-make'

## Umake nstall ----------------------------------------------------------------

#silentsudo 'Making directory for ide' mkdir -p "/opt/$USER/"
#silentsudo 'Changing ide directory owner' chown "$USER" "/opt/$USER/"

#silent 'Installing IntelliJ Idea' umake ide idea "/opt/$USER/tools/ide/idea"
#silent 'Installing Android Studio' umake android --accept-license "/opt/$USER/tools/ide/android-studio"

### Customization ==============================================================

title 'Customization'

## Wallpaper -------------------------------------------------------------------

if [[ "$(systemtype)" == 'GNOME' ]]
then
    gsettings set org.gnome.desktop.background primary-color '#20204a4a8787'
    gsettings set org.gnome.desktop.background picture-options 'none'
    gsettings set org.gnome.desktop.background picture-uri ''
fi

## Unity launcher icons --------------------------------------------------------

launcheradd "qtcreator"

### Application customization ==================================================

## qt creator ------------------------------------------------------------------

silent '' rm -f "${HOME}/.config"
silent '' mkdir -p "${HOME}/.config/QtProject"
silent '' touch "${HOME}/.config/QtProject/QtCreator.ini"

echo '[Directories]'                    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'BuildDirectory.Template=build/%{CurrentProject:Name}/%{CurrentBuild:Name}'    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo "Projects=${HOME}/Projects"        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'UseProjectsDirectory=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[TextEditor]'                     >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'FontFamily=Ubuntu Mono'           >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'FontSize=11'                      >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[textDisplaySettings]'            >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'DisplayFileEncoding=true'         >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'CenterCursorOnScroll=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'HighlightCurrentLine2Key=true'    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[textMarginSettings]'             >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'MarginColumn=80'                  >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'ShowMargin=true'                  >> "${HOME}/.config/QtProject/QtCreator.ini"

## astyle local ----------------------------------------------------------------

silent '' rm -f "${HOME}/.astylerc"
silent '' touch "${HOME}/.astylerc"

echo '--style=allman' >> "${HOME}/.astylerc"
echo '--indent=spaces=4' >> "${HOME}/.astylerc"
echo '--indent-namespaces' >> "${HOME}/.astylerc"
echo '--indent-preproc-define' >> "${HOME}/.astylerc"
echo '--indent-col1-comments' >> "${HOME}/.astylerc"
echo '#--break-blocks' >> "${HOME}/.astylerc"
echo '--unpad-paren' >> "${HOME}/.astylerc"
echo '--pad-header' >> "${HOME}/.astylerc"
echo '--pad-oper' >> "${HOME}/.astylerc"
echo '#--delete-empty-lines' >> "${HOME}/.astylerc"
echo '--align-pointer=type' >> "${HOME}/.astylerc"
echo '--align-reference=type' >> "${HOME}/.astylerc"
echo '--convert-tabs' >> "${HOME}/.astylerc"
echo '--close-templates' >> "${HOME}/.astylerc"
echo '--max-code-length=80' >> "${HOME}/.astylerc"
echo '--break-after-logical' >> "${HOME}/.astylerc"

## -----------------------------------------------------------------------------

msgdone
