#!/bin/bash

ROOT_PATH="$(cd "$(dirname "$0")" && pwd)"
cd "${ROOT_PATH}" || exit 1

. "${ROOT_PATH}/functions.sh"

### Customization ==============================================================

## Icon theme ------------------------------------------------------------------

icon_theme='Numix-Circle'

gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

## Cursor theme ----------------------------------------------------------------

cursor_theme='breeze_cursors'

gsettings set org.gnome.desktop.interface cursor-theme "${cursor_theme}"

## Gtk theme -------------------------------------------------------------------

if [[ "$(desktoptype)" == 'Unity' ]]
then
    theme_name='Numix'

elif [[ "$(desktoptype)" == 'GNOME' ]]
then
    theme_name='Paper'
fi

if [[ -n "${theme_name}" ]]
then
    gsettings set org.gnome.desktop.interface gtk-theme         "${theme_name}"
    gsettings set org.gnome.desktop.wm.preferences theme        "${theme_name}"
fi

## Gnome Shell extensions ------------------------------------------------------

if [[ "$(desktoptype)" == 'GNOME' ]]
then
    gsettingsadd org.gnome.shell enabled-extensions             'mediaplayer@patapon.info'
fi

## Fonts -----------------------------------------------------------------------

gsettings set org.gnome.desktop.interface font-name             'Ubuntu 10'
gsettings set org.gnome.desktop.interface document-font-name    'Noto Serif 10'
gsettings set org.gnome.desktop.interface monospace-font-name   'Ubuntu Mono 12'
gsettings set org.gnome.desktop.wm.preferences titlebar-font    'Ubuntu 10'

## Wallpaper -------------------------------------------------------------------

gsettings set org.gnome.desktop.background primary-color        '#204a87'
gsettings set org.gnome.desktop.background picture-options      'none'
gsettings set org.gnome.desktop.background picture-uri          ''

## Launcher applications -------------------------------------------------------

launcherclear
launcheradd 'nautilus'
launcheradd 'firefox'
launcheradd 'qtcreator'
launcheradd 'anjuta'
launcheradd 'org.gnome.Builder'
launcheradd 'gnome-terminal'

## Keyboard --------------------------------------------------------------------

gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Shift>Alt_L']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Primary><Shift>Alt_L']"

### Application customization ==================================================

## rhythmbox -------------------------------------------------------------------

gsettingsclear org.gnome.rhythmbox.plugins active-plugins

gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'replaygain'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'rb'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'power-manager'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'notification'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mpris'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'mmkeys'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'grilo'
gsettingsadd org.gnome.rhythmbox.plugins active-plugins 'generic-player'

## qt creator ------------------------------------------------------------------

rm -f    "${HOME}/.config/QtProject"
mkdir -p "${HOME}/.config/QtProject"
touch    "${HOME}/.config/QtProject/QtCreator.ini"

echo '[Directories]'                    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'BuildDirectory.Template=build/%{CurrentProject:Name}/%{CurrentBuild:Name}'    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo "Projects=${HOME}/Projects"        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'UseProjectsDirectory=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[TextEditor]'                     >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'FontFamily=Ubuntu Mono'           >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'FontSize=12'                      >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[textDisplaySettings]'            >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'DisplayFileEncoding=true'         >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'CenterCursorOnScroll=true'        >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'HighlightCurrentLine2Key=true'    >> "${HOME}/.config/QtProject/QtCreator.ini"
echo ''                                 >> "${HOME}/.config/QtProject/QtCreator.ini"
echo '[textMarginSettings]'             >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'MarginColumn=80'                  >> "${HOME}/.config/QtProject/QtCreator.ini"
echo 'ShowMargin=true'                  >> "${HOME}/.config/QtProject/QtCreator.ini"

## svn color side-by-side diff -------------------------------------------------

echo alias svndiff=\'svn --diff-cmd "colordiff" --extensions '"-y -W $(( $(tput cols) - 2 ))"' diff\' >> ~/.bash_aliases

## gedit -----------------------------------------------------------------------

gsettings set org.gnome.gedit.preferences.editor use-default-font       true

gsettings set org.gnome.gedit.preferences.editor display-line-numbers   true
gsettings set org.gnome.gedit.preferences.editor highlight-current-line true
gsettings set org.gnome.gedit.preferences.editor bracket-matching       true

gsettings set org.gnome.gedit.preferences.editor insert-spaces          true
gsettings set org.gnome.gedit.preferences.editor tabs-size              4

gsettings set org.gnome.gedit.preferences.editor display-right-margin   true
gsettings set org.gnome.gedit.preferences.editor right-margin-position  80

gsettings set org.gnome.gedit.preferences.editor syntax-highlighting    true

gsettings set org.gnome.gedit.preferences.editor scheme                 'kate'

gsettings set org.gnome.gedit.preferences.editor wrap-mode              'none'

gsettings set org.gnome.gedit.preferences.editor display-overview-map   true

gsettings set org.gnome.gedit.plugins active-plugins "['changecase', 'filebrowser', 'time', 'zeitgeistplugin', 'docinfo']"

## gnome builder ---------------------------------------------------------------

gsettings set org.gnome.builder.editor show-map                         true
gsettings set org.gnome.builder.editor font-name                        'Ubuntu Mono 12'

for lang in awk c changelog cmake cpp cpphdr css csv desktop diff dosbatch dot gdb-log html ini java js json markdown pascal php sh sql vala xml yaml
do
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ indent-width            -1
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ show-right-margin       true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ right-margin-position   80
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-spaces-instead-of-tabs true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ tab-width               4
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ trim-trailing-whitespace true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-matching-brace   true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ auto-indent             true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ overwrite-braces        true
done

for lang in makefile
do
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ indent-width            -1
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ show-right-margin       true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ right-margin-position   80
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-spaces-instead-of-tabs false
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ tab-width               4
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ trim-trailing-whitespace true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ insert-matching-brace   true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ auto-indent             true
    gsettings set org.gnome.builder.editor.language:/org/gnome/builder/editor/language/${lang}/ overwrite-braces        true
done

## gnome-terminal --------------------------------------------------------------

term_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | cut -d "'" -f 2)

gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false

gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" use-transparent-background true
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" background-transparency-percent 5
gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${term_profile}/" scrollbar-policy 'never'

## astyle local ----------------------------------------------------------------

silent '' rm -f "${HOME}/.astylerc"
silent '' touch "${HOME}/.astylerc"

echo '--style=allman'           >> "${HOME}/.astylerc"
echo '--indent=spaces=4'        >> "${HOME}/.astylerc"
echo '--indent-namespaces'      >> "${HOME}/.astylerc"
echo '--indent-preproc-define'  >> "${HOME}/.astylerc"
echo '--indent-col1-comments'   >> "${HOME}/.astylerc"
echo '#--break-blocks'          >> "${HOME}/.astylerc"
echo '--unpad-paren'            >> "${HOME}/.astylerc"
echo '--pad-header'             >> "${HOME}/.astylerc"
echo '--pad-oper'               >> "${HOME}/.astylerc"
echo '#--delete-empty-lines'    >> "${HOME}/.astylerc"
echo '--align-pointer=type'     >> "${HOME}/.astylerc"
echo '--align-reference=type'   >> "${HOME}/.astylerc"
echo '--convert-tabs'           >> "${HOME}/.astylerc"
echo '--close-templates'        >> "${HOME}/.astylerc"
echo '--max-code-length=80'     >> "${HOME}/.astylerc"
echo '--break-after-logical'    >> "${HOME}/.astylerc"

## Libreoffice  ----------------------------------------------------------------

mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar"
cp -f "${ROOT_PATH}/files/libreoffice/writer/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"
cp -f "${ROOT_PATH}/files/libreoffice/writer/textobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/swriter/toolbar/"

mkdir -p "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar"
cp -f "${ROOT_PATH}/files/libreoffice/calc/standardbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"
cp -f "${ROOT_PATH}/files/libreoffice/calc/formatobjectbar.xml" "${HOME}/.config/libreoffice/4/user/config/soffice.cfg/modules/scalc/toolbar/"


