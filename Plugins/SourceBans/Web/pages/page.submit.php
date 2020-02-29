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
*************************************************************************/

global $userbank, $theme;
use xPaw\SourceQuery\SourceQuery;
require_once(INCLUDES_PATH.'/SourceQuery/bootstrap.php');

if (!defined("IN_SB")) {
    echo "You should not be here. Only follow links!";
    die();
}
if (!Config::getBool('config.enablesubmit')) {
    print "<script>ShowBox('Error', 'This page is disabled. You should not be here.', 'red');</script>";
    PageDie();
}
if (!isset($_POST['subban']) || $_POST['subban'] != 1) {
    $SteamID       = "";
    $BanIP         = "";
    $PlayerName    = "";
    $BanReason     = "";
    $SubmitterName = "";
    $Email         = "";
    $SID           = -1;
} else {
    $SteamID       = trim(htmlspecialchars($_POST['SteamID']));
    $BanIP         = trim(htmlspecialchars($_POST['BanIP']));
    $PlayerName    = htmlspecialchars($_POST['PlayerName']);
    $BanReason     = htmlspecialchars($_POST['BanReason']);
    $SubmitterName = htmlspecialchars($_POST['SubmitName']);
    $Email         = trim(htmlspecialchars($_POST['EmailAddr']));
    $SID           = (int) $_POST['server'];
    $validsubmit   = true;
    $errors        = "";
    if ((strlen($SteamID) != 0 && $SteamID != "STEAM_0:") && !\SteamID\SteamID::isValidID($SteamID)) {
        $errors .= '* Please type a valid STEAM ID.<br>';
        $validsubmit = false;
    }
    if (strlen($BanIP) != 0 && !filter_var($BanIP, FILTER_VALIDATE_IP)) {
        $errors .= '* Please type a valid IP-address.<br>';
        $validsubmit = false;
    }
    if (strlen($PlayerName) == 0) {
        $errors .= '* You must include a player name<br>';
        $validsubmit = false;
    }
    if (strlen($BanReason) == 0) {
        $errors .= '* You must include comments<br>';
        $validsubmit = false;
    }
    if (!filter_var($Email, FILTER_VALIDATE_EMAIL)) {
        $errors .= '* You must include a valid email address<br>';
        $validsubmit = false;
    }
    if ($SID == -1) {
        $errors .= '* Please select a server.<br>';
        $validsubmit = false;
    }
    if (!empty($_FILES['demo_file']['name'])) {
        if (!checkExtension($_FILES['demo_file']['name'], ['zip', 'rar', 'dem', '7z', 'bz2', 'gz'])) {
            $errors .= '* A demo can only be a dem, zip, rar, 7z, bz2 or a gz filetype.<br>';
            $validsubmit = false;
        }
    }
    $checkres = $GLOBALS['db']->Execute("SELECT length FROM " . DB_PREFIX . "_bans WHERE authid = ? AND RemoveType IS NULL", array(
        $SteamID
    ));
    $numcheck = $checkres->RecordCount();
    if ($numcheck == 1 && $checkres->fields['length'] == 0) {
        $errors .= '* The player is already banned permanent.<br>';
        $validsubmit = false;
    }


    if (!$validsubmit) {
        print "<script>ShowBox('Error', '$errors', 'red');</script>";
    }

    if ($validsubmit) {
        $filename = md5($SteamID . time());
        //echo SB_DEMOS."/".$filename;
        $demo     = move_uploaded_file($_FILES['demo_file']['tmp_name'], SB_DEMOS . "/" . $filename);
        if ($demo || empty($_FILES['demo_file']['name'])) {
            if ($SID != 0) {
                $GLOBALS['PDO']->query("SELECT ip, port FROM `:prefix_servers` WHERE sid = :sid");
                $GLOBALS['PDO']->bind(':sid', $SID);
                $server = $GLOBALS['PDO']->single();

                $query = new SourceQuery();
                try {
                    $query->Connect($server['ip'], $server['port'], 1, SourceQuery::SOURCE);
                    $info = $query->GetInfo();
                } catch (Exception $e) {
                    $mailserver = "Server: Error Connecting (".$server['ip'].":".$server['port'].")\n";
                } finally {
                    $query->Disconnect();
                }

                if (!empty($info['HostName'])) {
                    $mailserver = "Server: ".$info['HostName']." (".$server['ip'].":".$server['port'].")\n";
                } else {
                    $mailserver = "Server: Error Connecting (".$server['ip'].":".$server['port'].")\n";
                }

                $GLOBALS['PDO']->query("SELECT m.mid FROM `:prefix_servers` as s LEFT JOIN `:prefix_mods` as m ON m.mid = s.modid WHERE s.sid = :sid");
                $GLOBALS['PDO']->bind(':sid', $SID);
                $modid = $GLOBALS['PDO']->single();
            } else {
                $mailserver = "Server: Other server\n";
                $modid['mid']   = 0;
            }
            if ($SteamID == "STEAM_0:") {
                $SteamID = "";
            }
            $pre = $GLOBALS['db']->Prepare("INSERT INTO " . DB_PREFIX . "_submissions(submitted,SteamId,name,email,ModID,reason,ip,subname,sip,archiv,server) VALUES (UNIX_TIMESTAMP(),?,?,?,?,?,?,?,?,0,?)");
            $GLOBALS['db']->Execute($pre, array(
                $SteamID,
                $PlayerName,
                $Email,
                $modid['mid'],
                $BanReason,
                $_SERVER['REMOTE_ADDR'],
                $SubmitterName,
                $BanIP,
                $SID
            ));
            $subid = (int) $GLOBALS['db']->Insert_ID();

            if (!empty($_FILES['demo_file']['name'])) {
                $GLOBALS['db']->Execute("INSERT INTO " . DB_PREFIX . "_demos(demid,demtype,filename,origname) VALUES (?, 'S', ?, ?)", array(
                    $subid,
                    $filename,
                    $_FILES['demo_file']['name']
                ));
            }
            $SteamID       = "";
            $BanIP         = "";
            $PlayerName    = "";
            $BanReason     = "";
            $SubmitterName = "";
            $Email         = "";
            $SID           = -1;

            // Send an email when ban was posted
            $headers = 'From: ' . SB_EMAIL . "\n" . 'X-Mailer: PHP/' . phpversion();

            $admins = $userbank->GetAllAdmins();
            $requri = substr($_SERVER['REQUEST_URI'], 0, strrpos($_SERVER['REQUEST_URI'], ".php") - 5);
            foreach ($admins as $admin) {
                $message = "";
                $message .= "Hello " . $admin['user'] . ",\n\n";
                $message .= "A new ban submission has been posted on your SourceBans page:\n\n";
                $message .= "Player: " . $_POST['PlayerName'] . " (" . $_POST['SteamID'] . ")\nDemo: " . (empty($_FILES['demo_file']['name']) ? 'no' : 'yes (http://' . $_SERVER['HTTP_HOST'] . $requri . 'getdemo.php?type=S&id=' . $subid . ')') . "\n" . $mailserver . "Reason: " . $_POST['BanReason'] . "\n\n";
                $message .= "Click the link below to view the current ban submissions.\n\nhttp://" . $_SERVER['HTTP_HOST'] . $requri . "index.php?p=admin&c=bans#%5E2";
                if ($userbank->HasAccess(ADMIN_OWNER | ADMIN_BAN_SUBMISSIONS, $admin['aid']) && $userbank->HasAccess(ADMIN_NOTIFY_SUB, $admin['aid'])) {
                    mail($admin['email'], "[SourceBans] Ban Submission Added", $message, $headers);
                }
            }
            print "<script>ShowBox('Successful', 'Your submission has been added into the database, and will be reviewed by one of our admins.', 'green');</script>";
        } else {
            print "<script>ShowBox('Error', 'There was an error uploading your demo to the server. Please try again later.', 'red');</script>";
            Log::add("e", "Demo Upload Failed", "A demo failed to upload for a submission from ($Email)");
        }
    }
}

//serverlist
$GLOBALS['PDO']->query("SELECT sid, ip, port FROM `:prefix_servers` WHERE enabled = 1 ORDER BY modid, sid");
$servers = $GLOBALS['PDO']->resultset();

foreach ($servers as $key => $server) {
    $query = new SourceQuery();
    try {
        $query->Connect($server['ip'], $server['port'], 1, SourceQuery::SOURCE);
        $info = $query->GetInfo();
        $servers[$key]['hostname'] = $info['HostName'];
    } catch (Exception $e) {
        $servers[$key]['hostname'] = "Error Connecting (".$server['ip'].":".$server['port'].")";
    } finally {
        $query->Disconnect();
    }
}

$theme->assign('STEAMID', $SteamID == "" ? "STEAM_0:" : $SteamID);
$theme->assign('ban_ip', $BanIP);
$theme->assign('ban_reason', $BanReason);
$theme->assign('player_name', $PlayerName);
$theme->assign('subplayer_name', $SubmitterName);
$theme->assign('player_email', $Email);
$theme->assign('server_list', $servers);
$theme->assign('server_selected', $SID);

$theme->display('page_submitban.tpl');
