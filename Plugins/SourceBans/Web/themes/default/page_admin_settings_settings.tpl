<form action="" method="post">
    <input type="hidden" name="settingsGroup" value="mainsettings" />
    <table width="99%" border="0" style="border-collapse:collapse;" id="group.details" cellpadding="3">
        <tr>
            <td valign="top" colspan="2"><h3>Main Settings</h3>For more information or help regarding a certain subject move your mouse over the question mark.<br /><br /></td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Title" message="Define the title shown in the title of your browser."}Title </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=1 class="textbox" id="template_title" name="template_title" value="{$config_title}" />
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Path to logo" message="Here you can define a new location for the logo, so you can use your own image."}Path to logo </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=2 class="textbox" id="template_logo" name="template_logo" value="{$config_logo}" />
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Min Password Length" message="Define the shortest length a password can be."}Min password length </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=3 class="textbox" id="config_password_minlength" name="config_password_minlength" value="{$config_min_password}" />
                </div>
                <div id="minpasslength.msg" class="badentry"></div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Date format" message="Here you can change the date format, displayed in the banlist and other pages."}Date format </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=4 class="textbox" id="config_dateformat" name="config_dateformat" value="{$config_dateformat}" />
                    <a href="http://www.php.net/date" target="_blank">See: PHP date()</a>
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Auth Maxlife" message="Max lifetime for auth tokens."}Auth Maxlife </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=4 class="textbox" id="auth_maxlife" name="auth_maxlife" value="{$auth_maxlife}" />
                    (in minutes)
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Auth Maxlife (remember me)" message="Max lifetime for auth tokens with remember me enabled."}Auth Maxlife (remember me) </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=4 class="textbox" id="auth_maxlife_remember" name="auth_maxlife_remember" value="{$auth_maxlife_remember}" />
                    (in minutes)
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Auth Maxlife (steam login)" message="Max lifetime for auth tokens via steam login."}Auth Maxlife (steam login) </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=4 class="textbox" id="auth_maxlife_steam" name="auth_maxlife_steam" value="{$auth_maxlife_steam}" />
                    (in minutes)
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Enable Debugmode" message="Check this box to enable the debugmode permanently."}Debugmode</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=6 name="config_debug" id="config_debug" />
                </div>
            </td>
        </tr>

        <tr>
            <td valign="top" colspan="2"><h3>Dashboard Settings</h3></td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Intro Title" message="Set the title for the dashboard introduction."}Intro Title </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=7 class="textbox" id="dash_intro_title" name="dash_intro_title" value="{$config_dash_title}" />
                </div>
                <div id="dash.intro.msg" class="badentry"></div></td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Intro Text" message="Set the text for the dashboard introduction."}Intro Text </div></td>
            <td><div align="left">  </div></td>
        </tr>
        <tr>
            <td valign="top" colspan="2"> <textarea TABINDEX=6 cols="80" rows="20" id="dash_intro_text" name="dash_intro_text">{$config_dash_text}</textarea>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Disable Log Popup" message="Check this box to disable the log info popup and use direct link."}Disable Log Popup</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=8 name="dash_nopopup" id="dash_nopopup" />
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top" colspan="2"><h3>Page Settings</h3></td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Enable Protest Ban" message="Check this box to enable the protest ban page."}Enable Protest Ban</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=9 name="enable_protest" id="enable_protest" />
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Enable Submit Ban" message="Check this box to enable the submit ban page."}Enable Submit Ban</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=10 name="enable_submit" id="enable_submit" />
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Enable Commslist" message="Check this box to enable the commslist page."}Enable Commslist</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=10 name="enable_commslist" id="enable_commslist" />
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Only Send One Email" message="Check this box to only send the protest notification email to the admin who banned the protesting player."}Only Send One Email</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=9 name="protest_emailonlyinvolved" id="protest_emailonlyinvolved" />
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Default Page" message="Choose the page that will be the first page people will see."}Default Page</div></td>
            <td>
                <div align="left">
                    <select class="select" TABINDEX=11 class="inputbox" name="default_page" id="default_page">
                        <option value="0">Dashboard</option>
                        <option value="1">Ban List</option>
                        <option value="2">Servers</option>
                        <option value="3">Submit a ban</option>
                        <option value="4">Protest a ban</option>
                    </select>
                </div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Clear Cache" message="Click this button, to clean the cache folder."}Clear Cache</div></td>
            <td>
                <div align="left">
                    {sb_button text="Clear Cache" onclick="xajax_ClearCache();" class="cancel" id="clearcache" submit=false}
                </div><div id="clearcache.msg"></div>
            </td>
        </tr>
        <tr>
            <td valign="top" colspan="2"><h3>Banlist Settings</h3></td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Items per page" message="Choose how many items to show on each page."}Items Per Page </div></td>
            <td>
                <div align="left">
                    <input type="text" TABINDEX=12 class="textbox" id="banlist_bansperpage" name="banlist_bansperpage" value="{$config_bans_per_page}" />
                </div>
                <div id="bansperpage.msg" class="badentry"></div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Hide Admin Name" message="Check this box, if you want to hide the name of the admin in the baninfo."}Hide Admin Name</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=13 name="banlist_hideadmname" id="banlist_hideadmname" />
                </div>
                <div id="banlist_hideadmname.msg" class="badentry"></div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="No Country Research" message="Check this box, if you don't want to display the country out of an IP in the banlist. Use if you encounter display problems."}No Country Research</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=14 name="banlist_nocountryfetch" id="banlist_nocountryfetch" />
                </div>
                <div id="banlist_nocountryfetch.msg" class="badentry"></div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Hide Player IP" message="Check this box, if you want to hide the player IP from the public."}Hide Player IP</div></td>
            <td>
                <div align="left">
                    <input type="checkbox" TABINDEX=15 name="banlist_hideplayerips" id="banlist_hideplayerips" />
                </div>
                <div id="banlist_hideplayerips.msg" class="badentry"></div>
            </td>
        </tr>
        <tr>
            <td valign="top"><div class="rowdesc">{help_icon title="Custom Banreasons" message="Type the custom banreasons you want to appear in the dropdown menu."}Custom Banreasons</div></td>
            <td>
                <div align="left">
                    <table width="100%" border="0" style="border-collapse:collapse;" id="custom.reasons" name="custom.reasons">
                        {foreach from="$bans_customreason" item="creason"}
                            <tr>
                                <td><input type="text" class="textbox" name="bans_customreason[]" id="bans_customreason[]" value="{$creason}"/></td>
                            </tr>
                        {/foreach}
                        <tr>
                            <td><input type="text" class="textbox" name="bans_customreason[]" id="bans_customreason[]"/></td>
                        </tr>
                        <tr>
                            <td><input type="text" class="textbox" name="bans_customreason[]" id="bans_customreason[]"/></td>
                        </tr>
                    </table>
                    <a href="javascript:void(0)" onclick="MoreFields();" title="Add more fields">[+]</a>
                </div>
                <div id="bans_customreason.msg" class="badentry"></div>
            </td>
        </tr>
        <tr>
            <td valign="top" colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>
                {sb_button text="Save Changes" class="ok" id="asettings" submit=true}
                &nbsp;
                {sb_button text="Back" class="cancel" id="aback"}
            </td>
        </tr>
    </table>
</form>
<script type="text/javascript" src="./includes/tinymce/tinymce.min.js"></script>
{literal}
    <script language="javascript" type="text/javascript">
        tinyMCE.init({
            selector: "textarea",
            height: 500,
            theme : "modern",
            plugins : "advlist, autolink, lists, link, image, charmap, print, preview, hr, anchor, pagebreak, searchreplace, wordcount, visualblocks, visualchars, code, fullscreen, insertdatetime, media, nonbreaking, save, table, contextmenu, directionality, emoticons, template, paste, textcolor, colorpicker, textpattern, imagetools, codesample, toc",
            extended_valid_elements : "a[name|href|target|title|onclick],img[class|src|border=0|alt|title|hspace|vspace|width|height|align|onmouseover|onmouseout|name],hr[class|width|size|noshade],font[face|size|color|style],span[class|align|style]"
        });
    </script>
{/literal}
