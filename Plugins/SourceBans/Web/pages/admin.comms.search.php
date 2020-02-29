<?php
/*************************************************************************
This file is part of SourceBans++

SourceBans++ (c) 2014-2019 by SourceBans++ Dev Team

The SourceBans++ Web panel is licensed under a
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

You should have received a copy of the license along with this
work.  If not, see <http://creativecommons.org/licenses/by-nc-sa/3.0/>.

This program is based off work covered by the following copyright(s):
SourceBans 1.4.11
Copyright © 2007-2014 SourceBans Team - Part of GameConnect
Licensed under CC-BY-NC-SA 3.0
Page: <http://www.sourcebans.net/> - <http://www.gameconnect.net/>

SourceComms 0.9.266
Copyright (C) 2013-2014 Alexandr Duplishchev
Licensed under GNU GPL version 3, or later.
Page: <https://forums.alliedmods.net/showthread.php?p=1883705> - <https://github.com/d-ai/SourceComms>
*************************************************************************/

global $userbank, $theme;
$admin_list   = $GLOBALS['db']->GetAll("SELECT * FROM `" . DB_PREFIX . "_admins` ORDER BY user ASC");
$server_list  = $GLOBALS['db']->Execute("SELECT sid, ip, port FROM `" . DB_PREFIX . "_servers` WHERE enabled = 1");
$servers      = array();
$serverscript = "<script type=\"text/javascript\">";
while (!$server_list->EOF) {
    $info = array();
    $serverscript .= "xajax_ServerHostPlayers('" . $server_list->fields[0] . "', 'id', 'ss" . $server_list->fields[0] . "', '', '', false, 200);";
    $info['sid']  = $server_list->fields[0];
    $info['ip']   = $server_list->fields[1];
    $info['port'] = $server_list->fields[2];
    array_push($servers, $info);
    $server_list->MoveNext();
}
$serverscript .= "</script>";
$page = isset($_GET['page']) ? $_GET['page'] : 1;

$theme->assign('hideplayerips', (Config::getBool('banlist.hideplayerips') && !$userbank->is_admin()));
$theme->assign('is_admin', $userbank->is_admin());
$theme->assign('admin_list', $admin_list);
$theme->assign('server_list', $servers);
$theme->assign('server_script', $serverscript);

$theme->display('box_admin_comms_search.tpl');
?>
<script type="text/javascript">
function switch_length(opt)
{
    if(opt.options[opt.selectedIndex].value=='other')
    {
        $('other_length').setStyle('display', 'block');
        $('other_length').focus();
        $('length').setStyle('width', '20px');
    } else {
        $('other_length').setStyle('display', 'none');
        $('length').setStyle('width', '210px');
    }
}
</script>
