# + --------------------------------------------------------------------------------------------------------------------------- +
# |
# |
# |  Gui Manager - Denizen Library
# |
# |
# + --------------------------------------------------------------------------------------------------------------------------- +
#
#
# @Htools               LLC
# @author               HollowTheSilver
# @date                 02/06/2023
# @script-version       DEV-1.0.5
# @denizen-build-1.2.6  REL-1783
#
#
# ------------------------------------------------------------------------------------------------------------------------------ +
#
#
# Description:
#   - A denizen library designed to manage multiple graphical user interfaces and handle many uix back-end tasks.
#
#   - This library is designed to simplify the front-end design pattern for gui type inventory scripts, and bring a fully functional
#   - graphical user interface to any denizen application hooking into the api's many utilities.
#
#   - This script is capable of managing multiple graphical user interface applications simultaneously with a single installation,
#   - and is considered as a denizen utility.
#
#
# ------------------------------------------------------------------------------------------------------------------------------ +
#
#
# Installation:
#   - Upload the 'Gui Manager' folder into your 'scripts' directory and reload denizen with /ex reload.
#
#
# Help:
#   - For library documentation please visit: https://htools/gui-manager/docs (coming soon)
#
#
# | ----------------------------------------------  GUI MANAGER | DENIZEN LIBRARY  ---------------------------------------------- | #



gui_manager:
    ####################################################################
    # | -------------------  |  Gui Manager  |  -------------------- | #
    ####################################################################
    # | ---                                                      --- | #
    # | ---  This script represents the main uix handler of any  --- | #
    # | ---  denizen application. These scripts should only be   --- | #
    # | ---  edited if you intend to directly adjust sensitive   --- | #
    # | ---  reference data and tasks that affect the operation  --- | #
    # | ---  and functionality of subsequent gui scripts.        --- | #
    # | ---                                                      --- | #
    ####################################################################
    type: world
    debug: false
    data:
        name: Gui<&sp>Manager
        version: 1.0.1
        config:
            ####################################################################
            # | ----------------------  |  Config  |  ---------------------- | #
            ####################################################################
            # | ---                                                      --- | #
            # | ---  This file represents the default configuration for  --- | #
            # | ---  uix manager operations, affecting all scripts that  --- | #
            # | ---  utilize the handler script.                         --- | #
            # | ---                                                      --- | #
            ####################################################################
            prefixes:
                main: <&lb>Gui<&sp>Manager<&rb>
            sounds:
                left-click-button: ui_button_click
                confirm-dialog: entity_experience_orb_pickup
            ids:
                # |--------------------------------------------------------------------| #
                # | ---   This string value represents the series of characters    --- | #
                # | ---   the application manager searches for when iterating      --- | #
                # | ---   over loaded inventory scripts. The variable '<[app-id]>' --- | #
                # | ---   represents your registered application identifier.       --- | #
                # | ---   Any inventory scripts that do not begin with the value   --- | #
                # | ---   below will not be registered into the app manager.       --- | #
                # | ---   This value should not contain spaces, only underscores.  --- | #
                # |--------------------------------------------------------------------| #
                valid-gui: <[app-id]>_gui_
                blacklist:
                    # | ---  gui-id cache blacklist  --- | #
                    - dialog
                    - select
            dialog:
                # |--------------------------------------------------------------| #
                # | ---   This value represents the duration the input will  --- | #
                # | ---   take to timeout the dialog event.                  --- | #
                # | ---   This value can accept a suffix of 's|m|h|d' and    --- | #
                # | ---   defaults to seconds if none is provided.           --- | #
                # |--------------------------------------------------------------| #
                input-timeout: 90s
                # | ---  cancel input dialog event keywords  --- | #
                cancel-keywords:
                    - cancel
                    - stop
                    - exit
            dependencies:
                # |--------------------------------------------------------------| #
                # | ---   These dependencies are treated as priorty lists    --- | #
                # | ---   that are checked when the gui manager utilizes a   --- | #
                # | ---   dependency throughout run time. The data is read   --- | #
                # | ---   in descending order, so this means that in cases   --- | #
                # | ---   where only one element of a specific category is   --- | #
                # | ---   required, such as a permissions plugin, the first  --- | #
                # | ---   element found will be chosen. You should consider  --- | #
                # | ---   these facts when listing related plugins.          --- | #
                # |--------------------------------------------------------------| #
                plugins:
                    # | ---  plugin name  --- | #
                    - UltraPermissions
                    - LuckPerms
                    - Essentials
            log:
                dir: plugins/Denizen/data/logs/<script.name>/
                max: 10



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    events:
        ##############################################
        # | ---  |      manager events      |  --- | #
        ##############################################
        on script generates error:
            - if ( <context.message.contains_text[testing/debugging<&sp>only]> ):
                # |------- suppress list_flags warning -------| #
                - determine cancelled

        ############################################
        # | ---  |      input events      |  --- | #
        ############################################
        on player flagged:gui_manager.awaiting_input quits:
            - ~run <script.name> path:cancel

        #############################################
        # | ---  |      select events      |  --- | #
        #############################################
        on player flagged:gui_manager.awaiting_select closes gui_manager_gui_select:
            - ~run <script.name> path:cancel

        on player flagged:gui_manager.awaiting_select closes player:
            - ~run <script.name> path:cancel

        on player flagged:gui_manager.awaiting_select quits:
            - ~run <script.name> path:cancel

        after player flagged:gui_manager.awaiting_select left clicks item in gui_manager_gui_select:
            - if ( <player.has_flag[<script.name>.awaiting_select]> ):
                - flag <player> <script.name>.select:<context.item>
                - flag <player> <script.name>.awaiting_select:!

        after player flagged:gui_manager.awaiting_select left clicks item in player:
            - determine cancelled passively
            - if ( <player.has_flag[<script.name>.awaiting_select]> ):
                - flag <player> <script.name>.select:<context.item>
                - flag <player> <script.name>.awaiting_select:!

        #############################################
        # | ---  |      dialog events      |  --- | #
        #############################################
        on player flagged:gui_manager.awaiting_dialog closes gui_manager_gui_dialog:
            - ~run <script.name> path:cancel

        on player flagged:gui_manager.awaiting_dialog quits:
            - ~run <script.name> path:cancel

        on player flagged:gui_manager.awaiting_input chats:
            - determine passively cancelled
            - if ( <player.has_flag[<script.name>.awaiting_input]> ):
                - flag <player> <script.name>.input:<context.message>
                - flag <player> <script.name>.awaiting_input:!

        after player flagged:gui_manager.awaiting_dialog left clicks item_flagged:gui-button in gui_manager_gui_dialog:
            - define button-id <context.item.flag[gui-button]||null>
            - choose <[button-id]>:
                - default:
                    # | --- invalid --- | #
                    - define message "'gui-button' flag not set properly."
                    - ~run <script.name> path:logger.log def.level:error def.task:dialog def.message:<[message]>
                - case 1 t true confirm yes:
                    # | --- confirm --- | #
                    - flag <player> <script.name>.dialog:true
                - case 0 f false deny no:
                    # | --- deny --- | #
                    - flag <player> <script.name>.dialog:false



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    debugger:

        on:
            ####################################
            # | ---  |    debug on    |  --- | #
            ####################################
            # | ---                      --- | #
            # | ---  Required:  none     --- | #
            # | ---                      --- | #
            ####################################
            # | ---                      --- | #
            # | ---  Returns:  none      --- | #
            # | ---                      --- | #
            ####################################
            - flag <player> <script.name>.debug:true

        off:
            #####################################
            # | ---  |    debug off    |  --- | #
            #####################################
            # | ---                       --- | #
            # | ---  Required:  none      --- | #
            # | ---                       --- | #
            #####################################
            # | ---                       --- | #
            # | ---  Returns:  none       --- | #
            # | ---                       --- | #
            #####################################
            - flag <player> <script.name>.debug:false



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    logger:

        log:
            #########################################################
            # | ---  |             log message             |  --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Required:  level | task | message        --- | #
            # | ---                                           --- | #
            # | ---  Optional:  app-id                        --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Returns:  none                           --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Run: true | Await: true | Inject: true   --- | #
            # | ---                                           --- | #
            #########################################################
            # |------- define data -------| #
            - if ( not <[app-id].exists> ):
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
            - define prefix <script.parsed_key[data.config.prefixes.main]>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                - if ( <[task].exists> ):
                    - if ( <[level].exists> ):
                        - if ( <[message].exists> ):
                            - define dir <script.parsed_key[data.config.log.dir].if_null[plugins/Denizen/data/logs/<script.name>/]>
                            - if ( <[dir].ends_with[/]> ):
                                - define path <[dir]><[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
                            - else:
                                - define path <[dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
                            - define message "<[prefix]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name> - <[task]>() -<&gt> <[message]>"
                            - choose <[level]>:
                                - default:
                                    # |------- invalid 'level' parameter -------| #
                                    - define message "<[prefix]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name> - <[task]>() -<&gt> '<[level]>' isn't a valid level."
                                    - if ( <player.flag[<script.name>.debug]> ):
                                        - ~debug log <[message]>
                                    - log <[message]> type:warning file:<[path]>
                                - case info:
                                    # |------- log info -------| #
                                    - if ( <player.flag[<script.name>.debug]> ):
                                        - ~debug log <[message]>
                                    - log <[message]> file:<[path]>
                                - case warning warn:
                                    # |------- log warning -------| #
                                    - ~debug log <[message]>
                                    - log <[message]> type:warning file:<[path]>
                                - case error:
                                    # |------- log error -------| #
                                    - ~debug log <[message]>
                                    - log <[message]> type:severe file:<[path]>
                        - else:
                            # |------- missing parameter 'message' -------| #
                            - define message "<[prefix]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name> - <[task]>() -<&gt> missing required parameter 'message'."
                            - ~debug error <[message]>
                    - else:
                        # |------- missing parameter 'level' -------| #
                        - define message "<[prefix]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name> - <[task]>() -<&gt> missing required parameter 'level'."
                        - ~debug error <[message]>
                - else:
                    # |------- missing parameter 'task' -------| #
                    - define message "<[prefix]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name> - logger() -<&gt> missing required parameter 'task'."
                    - ~debug error <[message]>
            - else:
                # |------- missing parameter 'app-id' -------| #
                - define message "<[prefix]> <player.name> - <[task]>() -<&gt> couldn't locate 'app-id'. Missing 'opened' flag."
                - ~debug error <[message]>

        purge:
            ########################################################
            # | ---  |             purge logs             |  --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Required:  none                         --- | #
            # | ---                                          --- | #
            # | ---  Optional:  app-id                       --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Returns:  bool                          --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Run: true | Await: true | Inject: true  --- | #
            # | ---                                          --- | #
            ########################################################
            # |------- define data -------| #
            - if ( not <[app-id].exists> ):
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
            - if ( <[app-id]> != null ):
                # |------- parse -------| #
                - define message "purge triggered. Gathering logs..."
                - ~run <script.name> path:logger.log def.level:info def.task:purge def.message:<[message]>
                - define dir <script.parsed_key[data.config.log.dir].if_null[plugins/Denizen/data/logs/<script.name>/]>
                - if ( <[dir].ends_with[/]> ):
                    - define path <[dir].after[denizen/]><[app-id]>
                - else:
                    - define path <[dir].after[denizen/]>/<[app-id]>
                - define latest <util.time_now.format[MM-dd-yyyy]>
                - if ( <util.has_file[<[path]>/<[latest]>.txt]> ):
                    - define logs <util.list_files[<[path]>].if_null[<list[<empty>]>]>
                    - define max <script.data_key[data.config.log.max].if_null[6]>
                    - define amount <[logs].exclude[<[latest]>.txt].size>
                    - if ( <[max].is_integer> ):
                        - if ( <[logs].size> >= <[max]> ):
                            # |------- purge -------| #
                            - foreach <[logs].exclude[<[latest]>.txt].if_null[<[logs]>]> as:log:
                                - adjust server delete_file:<[path]>/<[log]>
                            - if ( <[amount]> > 1 ):
                                - define message "'<[amount]>' logs purged."
                            - else:
                                - define message "'<[amount]>' log purged."
                            - ~run <script.name> path:logger.log def.level:info def.task:purge def.message:<[message]>
                        - else:
                            # |------- cancel -------| #
                            - if ( <[amount]> > 1 ):
                                - define message "purge cancelled. '<[logs].size>' logs found."
                            - else:
                                - define message "purge cancelled. '<[logs].size>' log found."
                            - ~run <script.name> path:logger.log def.level:info def.task:purge def.message:<[message]>
                    - else:
                        # |------- invalid int -------| #
                        - define message "parameter '<[max]>'(max) is not of type integer."
                        - ~run <script.name> path:logger.log def.level:error def.task:purge def.message:<[message]>
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    app:

        init:
            #########################################################
            # | ---  |               run app               |  --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Required:  app-id                        --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Returns:  bool                           --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Run: true | Await: true | Inject: false  --- | #
            # | ---                                           --- | #
            #########################################################
            - if not ( <player.has_flag[<script.name>.debug]> ):
                - flag <player> <script.name>.debug:false
            # |------- parameter check -------| #
            - if ( <[app-id].exists> ):
                # |------- run -------| #
                - flag <player> <script.name>.opened:<[app-id]>
                - define message "initializing '<[app-id]>'..."
                - ~run <script.name> path:logger.log def.level:info def.task:init def.message:<[message]>
                # |------- validate -------| #
                - ~run <script.name> path:validate.app save:validated
                - if ( not <entry[validated].created_queue.determination.get[1]> ):
                    # |------- failed -------| #
                    - define message "'<[app-id]>' run failed."
                    - ~run <script.name> path:logger.log def.level:error def.task:init def.message:<[message]>
                    - determine false
                # |------- successful -------| #
                - if ( <util.random.int[0].to[20]> == 1 ):
                    - ~run <script.name> path:logger.purge
                - determine true
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "missing 'app-id' parameter. Exiting manager..."
                - determine false

        build:
            #########################################################
            # | ---  |              build ast              |  --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Required:  none                          --- | #
            # | ---                                           --- | #
            # | ---  Optional:  app-id                        --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Returns:  bool                           --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Run: true | Await: true | Inject: false  --- | #
            # | ---                                           --- | #
            #########################################################
            # |------- task data -------| #
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened].if_null[null]>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                # |------- parse scripts -------| #
                - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                - foreach <util.scripts> as:script:
                    - if ( <[script].container_type> == inventory ) && ( <[script].contains_text[<[identifier]>]> ):
                        - define directory <[script].relative_filename.before_last[/]>
                        - if ( not <[directories].if_null[<list[<empty>]>].contains[<[directory]>]> ):
                            # |------- set path -------| #
                            - define directories:->:<[directory]>
                        # |------- define lineage -------| #
                        - define parent <script[<[script]>].data_key[data.root].if_null[null]>
                        - if ( <[parent]> == null ) || ( <[parent]> == <empty> ):
                            # |------- set initial -------| #
                            - define initial:->:<[script].name.after[<[identifier]>]>
                        - if ( <[parent]> != null ):
                            - if ( not <[parent].contains_text[<[identifier]>]> ):
                                - define parent <[identifier]><[parent]>
                            - if ( <script[<[parent]>].exists> ):
                                # |------- set lineage -------| #
                                - define <[parent]>:->:<[script].name.after[<[identifier]>]>
                                - if ( not <[lineage].if_null[<list[<empty>]>].contains[<[parent].after[<[identifier]>]>]> ):
                                    - define lineage:->:<[parent].after[<[identifier]>]>
                            - else:
                                # |------- invalid parent -------| #
                                - define message "invalid 'root' for '<[script].name.after[<[identifier]>]>' gui. Skipping..."
                                - ~run <script.name> path:logger.log def.level:warning def.task:build def.message:<[message]>

                # |------- build abstract syntax tree -------| #
                - if ( <[initial].size.if_null[0]> >= 1 ):
                    # |------- build intial -------| #
                    - foreach <[initial]> as:root-node:
                        - define ast.<[root-node]>:<empty>
                    - while ( <[lineage].size.if_null[0]> >= 1 ):
                        # |------- parse branches -------| #
                        - foreach <[lineage]> as:gui-id:
                            # |------- crawl lineage -------| #
                            - foreach <[ast].deep_keys> as:branch:
                                - if ( <[gui-id]> == <[branch]> ):
                                    - foreach <definition[<[identifier]><[gui-id]>]> as:child:
                                        - define ast.<[branch]>.<[child]>:<empty>
                                    - define lineage:<-:<[gui-id]>
                                - else if ( <[branch].split[.].if_null[<list[<empty>]>]> contains <[gui-id]> ):
                                    # |------- crawl siblings -------| #
                                    - foreach <[branch].split[.]> as:leaf:
                                        - if ( <[gui-id]> == <[leaf]> ):
                                            - foreach <definition[<[identifier]><[gui-id]>]> as:child:
                                                - define ast.<[branch].before[.<[leaf]>]>.<[leaf]>.<[child]>:<empty>
                                            - define lineage:<-:<[gui-id]>
                - else:
                    # |------- missing initial-id -------| #
                    - define message "missing initial-id for '<[app-id]>'. An application requires at least one inventory script without a root data property."
                    - ~run <script.name> path:logger.log def.level:error def.task:build def.message:<[message]>
                    - determine false
                # |------- validate -------| #
                - if ( <[ast].exists> ) && ( <[lineage].size.if_null[0]> == 0 ):
                    - if ( <[directories].size.if_null[0]> == 1 ):
                        # |------- successful -------| #
                        - flag server <script.name>.apps.<[app-id]>.ast:<[ast]>
                        - flag server <script.name>.apps.<[app-id]>.path:<[directories].get[1]>
                        - determine true
                    - else:
                        # |------- invalid directory -------| #
                        - define message "directory error. All related gui script(s) must be in a single (1) directory."
                        - ~run <script.name> path:logger.log def.level:error def.task:build def.message:<[message]>
                        - determine false
                - else:
                    # |------- invalid ast -------| #
                    - define message "application compilation failed."
                    - ~run <script.name> path:logger.log def.level:error def.task:build def.message:<[message]>
                    - determine false
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                - determine false



# | ------------------------------------------------------------------------------------------------------------------------------ | #



        get:

            version:
                #########################################################
                # | ---  |             get version             |  --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Required:  none                          --- | #
                # | ---                                           --- | #
                # | ---  Optional:  app-id                        --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Returns:  str | bool                     --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Run: true | Await: true | Inject: false  --- | #
                # | ---                                           --- | #
                #########################################################
                - define version <script.data_key[data.version].if_null[null]>
                - if ( <[version]> != null ):
                    - determine <[version]>
                - else:
                    - define message "version could not be located."
                    - ~run <script.name> path:logger.log def.level:warning def.task:get.version def.message:<[message]>
                    - determine false

            ast:
                #########################################################
                # | ---  |               get ast               |  --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Required:  none                          --- | #
                # | ---                                           --- | #
                # | ---  Optional:  app-id                        --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Returns:  map | bool                     --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Run: true | Await: true | Inject: false  --- | #
                # | ---                                           --- | #
                #########################################################
                # |------- define data -------| #
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
                # |------- parameter check -------| #
                - if ( <[app-id]> != null ):
                    - define ast <server.flag[<script.name>.apps.<[app-id]>.ast].if_null[null]>
                    - if ( <[ast]> != null ) && ( <[ast].keys.any> ):
                        - determine <[ast]>
                    - else:
                        # |------- missing ast -------| #
                        - define message "'<[app-id]>' ast could not be located."
                        - ~run <script.name> path:logger.log def.level:warning def.task:get.ast def.message:<[message]>
                        - determine false
                - else:
                    # |------- missing parameter 'app-id' -------| #
                    - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                    - determine false

            root:
                ########################################################
                # | ---  |              get root              |  --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Required:  none                         --- | #
                # | ---                                          --- | #
                # | ---  Optional:  app-id | gui-id              --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Returns:  list | bool                   --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Run: true | Await: true | Inject: false --- | #
                # | ---                                          --- | #
                ########################################################
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
                # |------- parameter check -------| #
                - if ( <[app-id]> != null ):
                    - define ast <server.flag[<script.name>.apps.<[app-id]>.ast].if_null[null]>
                    - if ( <[ast]> != null ):
                        - define blacklist <script.data_key[data.config.ids].get[blacklist]||<list[<empty>]>>
                        - if ( <[gui-id].exists> ):
                            - if ( <[gui-id].keys.size.exists> ):
                                - define gui-id <[gui-id].get[2]||null>
                            - if ( not <[blacklist].contains[<[gui-id]>]> ):
                                # |------- parse ast -------| #
                                - foreach <[ast].deep_keys> as:branch:
                                    - if ( <[gui-id]> == <[branch]> ):
                                        - determine <[branch]>
                                    - else if ( <[branch].split[.].if_null[<list[<empty>]>]> contains <[gui-id]> ):
                                        - foreach <[branch].split[.]> as:leaf:
                                            - if ( <[gui-id]> == <[leaf]> ):
                                                - determine <[branch].split[.].first>
                        # |------- default -------| #
                        - foreach <[ast].keys> as:root:
                            - if ( <[ast].get[<[root]>]||<empty>> != <empty> ):
                                # |------- get eldest -------| #
                                - if ( not <[blacklist].contains[<[gui-id]>]> ):
                                    - define message "defaulting to '<[root]>'."
                                    - ~run <script.name> path:logger.log def.level:warning def.task:get.root def.message:<[message]>
                                - determine <[root]>
                        - if ( <[ast].keys.first.exists> ):
                            # |------- get first -------| #
                            - if ( not <[blacklist].contains[<[gui-id]>]> ):
                                - define message "defaulting to '<[ast].keys.first>'."
                                - ~run <script.name> path:logger.log def.level:warning def.task:get.root def.message:<[message]>
                            - determine <[ast].keys.first>
                        - else:
                            # |------- missing root -------| #
                            - define message "root for '<[app-id]>' could not be located."
                            - ~run <script.name> path:logger.log def.level:error def.task:get.root def.message:<[message]>
                            - determine false
                    - else:
                        # |------- missing ast -------| #
                        - define message "'<[gui-id]>' has not been built."
                        - ~run <script.name> path:logger.log def.level:error def.task:get.root def.message:<[message]>
                        - determine false
                - else:
                    # |------- missing parameter 'app-id' -------| #
                    - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                    - determine false

            parent:
                ########################################################
                # | ---  |             get parent             |  --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Required:  gui-id                       --- | #
                # | ---                                          --- | #
                # | ---  Optional:  app-id                       --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Returns:  str | bool                    --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Run: true | Await: true | Inject: false --- | #
                # | ---                                          --- | #
                ########################################################
                # |------- task data -------| #
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
                # |------- parameter check -------| #
                - if ( <[app-id]> != null ):
                    - if ( <[gui-id]||null> != null ):
                        # |------- parse root -------| #
                        - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                        - if ( not <[gui-id].contains_text[<[identifier]>]> ):
                            - define root <script[<[identifier]><[gui-id]>].data_key[data.root].if_null[null]>
                        - else:
                            - define root <script[<[gui-id]>].data_key[data.root].if_null[null]>
                        - if ( <[root]> != null ) && ( <[root]> != <empty> ):
                            - if ( <script[<[root]>].exists> ) || ( <script[<[identifier]><[root]>].exists> ) :
                                # |------- parse root-id -------| #
                                - run <script.name> path:validate.id def.gui-id:<[root]> save:parent
                                - define parent <entry[parent].created_queue.determination.get[1].if_null[null]>
                                - if ( <[parent]> != null ):
                                    # |------- successful -------| #
                                    - determine <[parent]>
                                - else:
                                    # |------- invalid root-id -------| #
                                    - define message "parent '<[root]>_id' could not be validated."
                                    - ~run <script.name> path:logger.log def.level:error def.task:get.parent def.message:<[message]>
                                    - determine false
                        # |------- parse ast -------| #
                        - define ast <server.flag[<script.name>.apps.<[app-id]>.ast]||null>
                        - if ( <[ast]> != null ):
                            - foreach <[ast].deep_keys> as:branch:
                                - if ( <[gui-id]> == <[branch]> ) || ( <[gui-id]> == <[branch].split[.].first||null> ):
                                    - determine false
                            # |------- invalid root -------| #
                            - define message "invalid 'root' for '<[gui-id]>'"
                            - ~run <script.name> path:logger.log def.level:error def.task:get.parent def.message:<[message]>
                            - determine false
                        - else:
                            # |------- missing ast -------| #
                            - define message "app '<[app-id]>' has not been registered with the manager."
                            - ~run <script.name> path:logger.log def.level:error def.task:get.parent def.message:<[message]>
                            - determine false
                    - else:
                        # |------- missing parameter 'gui-id' -------| #
                        - define message "couldn't locate parameter 'gui-id'."
                        - ~run <script.name> path:logger.log def.level:error def.task:get.parent def.message:<[message]>
                        - determine false
                - else:
                    # |------- missing parameter 'app-id' -------| #
                    - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                    - determine false

            siblings:
                ########################################################
                # | ---  |            get siblings            |  --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Required:  gui-id                       --- | #
                # | ---                                          --- | #
                # | ---  Optional:  app-id                       --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Returns:  list | bool                   --- | #
                # | ---                                          --- | #
                ########################################################
                # | ---                                          --- | #
                # | ---  Run: true | Await: true | Inject: false --- | #
                # | ---                                          --- | #
                ########################################################
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
                # |------- parameter check -------| #
                - if ( <[app-id]> != null ):
                    - if ( <[gui-id]||null> != null ):
                        - define ast <server.flag[<script.name>.apps.<[app-id]>.ast]||null>
                        - if ( <[ast]> != null ):
                            - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                            - if ( not <[gui-id].contains_text[<[identifier]>]> ):
                                - define root <script[<[identifier]><[gui-id]>].data_key[data.root].if_null[null]>
                            - else:
                                - define root <script[<[gui-id]>].data_key[data.root].if_null[null]>
                            - if ( <[root]> == null ) || ( <[root]> == <empty> ):
                                # |------- return root-ids -------| #
                                - determine <[ast].keys>
                            - else if ( <[root]> != null ):
                                - if ( <[root].contains_text[<[identifier]>]> ):
                                    - define root <[root].after[<[identifier]>]>
                                # |------- parse ast -------| #
                                - foreach <[ast].deep_keys> as:branch:
                                    - if ( <[root]> == <[branch]> ):
                                        - define siblings <[ast].get[<[branch]>].keys.if_null[null]>
                                        - if ( <[siblings]> != null ):
                                            - determine <[siblings].keys.exclude[<[gui-id]>]>
                                        - else:
                                            - determine <list[<empty>]>
                                    - else if ( <[branch].split[.].if_null[<list[<empty>]>]> contains <[gui-id]> ):
                                        - foreach <[branch].split[.]> as:leaf:
                                            - if ( <[root]> == <[leaf]> ):
                                                - define siblings <[ast].deep_get[<[branch].before[.<[root]>]>.<[root]>].if_null[null]>
                                                - if ( <[siblings]> != null ):
                                                    - determine <[siblings].keys.exclude[<[gui-id]>]>
                                                - else:
                                                    - determine <list[<empty>]>
                            # |------- couldn't locate -------| #
                            - define message "siblings for '<[gui-id]>' could not be located."
                            - ~run <script.name> path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
                            - determine false
                        - else:
                            # |------- missing ast -------| #
                            - define message "'<[gui-id]>' has not been built."
                            - ~run <script.name> path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
                            - determine false
                    - else:
                        # |------- missing parameter 'gui-id' -------| #
                        - define message "couldn't locate parameter 'gui-id'."
                        - ~run <script.name> path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
                        - determine false
                - else:
                    # |------- missing parameter 'app-id' -------| #
                    - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                    - determine false



# | ------------------------------------------------------------------------------------------------------------------------------ | #



        reset:

            ast:
                #########################################################
                # | ---  |              reset ast              |  --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Required:  none                          --- | #
                # | ---                                           --- | #
                # | ---  Optional:  app-id                        --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Returns:  bool                           --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Run: true | Await: true | Inject: true   --- | #
                # | ---                                           --- | #
                #########################################################
                - if ( not <[app-id].exists> ):
                    - define app-id <player.flag[<script.name>.opened].if_null[null]>
                # |------- parameter check -------| #
                - if ( <[app-id]> != null ):
                    - define cached <server.flag[<script.name>.apps.<[app-id]>.ast].if_null[null]>
                    - ~run <script.name> path:app.build save:build
                    - if ( not <entry[build].created_queue.determination.get[1]> ):
                        # |------- failed -------| #
                        - if ( <[cached]> != null ):
                            - flag server <script.name>.apps.<[app-id]>.ast:<[cached]>
                        - define message "'<[app-id]>' ast reset failed."
                        - ~run <script.name> path:logger.log def.level:error def.task:reset.ast def.message:<[message]>
                        - determine false
                    - else:
                        - ~run <script.name> path:logger.log def.level:info def.task:reset.ast def.message:<server.flag[<script.name>.apps.<[app-id]>.ast].to_json>
                        - determine true
                - else:
                    # |------- missing parameter 'app-id' -------| #
                    - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                    - determine false

            nav:
                #########################################################
                # | ---  |              reset nav              |  --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Required:  none                          --- | #
                # | ---                                           --- | #
                # | ---  Optional:  app-id                        --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Returns:  none                           --- | #
                # | ---                                           --- | #
                #########################################################
                # | ---                                           --- | #
                # | ---  Run: true | Await: true | Inject: true   --- | #
                # | ---                                           --- | #
                #########################################################
                - flag <player> <script.name>.current:!
                - flag <player> <script.name>.next:<list[<empty>]>
                - flag <player> <script.name>.previous:<list[<empty>]>
                - define message "navigation flags reset."
                - ~run <script.name> path:logger.log def.level:info def.task:reset.nav def.message:<[message]>



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    validate:

        id:
            #########################################################
            # | ---  |             validate id             |  --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Required:  none                          --- | #
            # | ---                                           --- | #
            # | ---  Optional:  app-id | gui-id               --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Returns:  str | map                      --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Run: true | Await: true | Inject: false  --- | #
            # | ---                                           --- | #
            #########################################################
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened].if_null[null]>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                # |------- navigation data -------| #
                - define current <player.flag[<script.name>.current]||null>
                - define next <player.flag[<script.name>.next]||<list[<empty>]>>
                - define previous <player.flag[<script.name>.previous]||<list[<empty>]>>
                - if ( not <[gui-id].exists> ) || ( <[gui-id]> == null ):
                    # |------- null check -------| #
                    - determine <[current]>
                # |------- parse gui-id -------| #
                - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]>>
                - define parsed <[gui-id].split[_]||<list[<empty>]>>
                - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                - if ( <[gui-id].contains_text[<[identifier]>]> ):
                    - define gui-id <[gui-id].after[<[identifier]>]||<[gui-id]>>
                - if ( <[previous]> contains <[gui-id]> ) && ( not <[ignore]||true> ):
                    - define gui-id previous_page_<[previous].get[<[previous].find[<[gui-id]>]>].to[<[previous].find[<[previous].last>]>].size>
                    - define parsed <[gui-id].split[_]||<list[<empty>]>>
                - if ( <[parsed].first.equals[next]> || <[parsed].first.equals[previous]> ) && ( <[parsed].last> == page || <[parsed].last.is_integer> ):
                    # |------- parse cache -------| #
                    - if ( <[parsed].last.is_integer> ):
                        - define cache-id <[parsed].last>
                    - else:
                        - define cache-id 1
                    - if ( <[cache-id].exists> ) && ( <[cache-id].is_integer> ):
                        - choose <[parsed].first>:
                            - default:
                                # |------- invalid -------| #
                                - determine <map[1=null;2=null;3=null;4=false]>
                            - case next:
                                # |------- parse next -------| #
                                - if ( <[cache-id]> > 1 ):
                                    - define cache-id <[cache-id].sub[1]>
                                    - define iterate true
                                - if ( <[next]> contains <[current]> ):
                                    - define cached <[next].exclude[<[current]>].get[1].to[<[cache-id]>]||<list[<empty>]>>
                                - else:
                                    - define cached <[next].get[1].to[<[cache-id]>]||<list[<empty>]>>
                                # |------- determine next -------| #
                                - define gui-id <[cached].last||null>
                                - definemap page-cache:
                                    1: <[parsed].first>
                                    2: <[gui-id]>
                                    3: <[cached]>
                                    4: <[iterate]||false>
                                - determine <[page-cache]>
                            - case previous:
                                # |------- parse previous -------| #
                                - define removed <[previous].reverse.get[1].to[<[cache-id]>].reverse||<list[<empty>]>>
                                - define cached <[previous].reverse.remove[1].to[<[cache-id]>].reverse||<list[<empty>]>>
                                # |------- determine previous -------| #
                                - define gui-id <[removed].first||null>
                                - definemap page-cache:
                                    1: <[parsed].first>
                                    2: <[gui-id]>
                                    3: <[cached]>
                                    4: <[iterate]||false>
                                - determine <[page-cache]>
                - else:
                    - determine <[gui-id]>
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."

        app:
            ########################################################
            # | ---  |            validate app            |  --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Required:  none                         --- | #
            # | ---                                          --- | #
            # | ---  Optional:  app-id                       --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Returns:  bool                          --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Run: true | Await: true | Inject: false --- | #
            # | ---                                          --- | #
            ########################################################
            # |------- define data -------| #
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened].if_null[null]>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                # |------- validate app -------| #
                - if ( not <server.flag[<script.name>.apps.<[app-id]>].exists> ):
                    # |------- missing app -------| #
                    - define message "'<[app-id]>' is not registered."
                    - ~run <script.name> path:logger.log def.level:warning def.task:validate.app def.message:<[message]>
                    - define message "registering '<[app-id]>'..."
                    - ~run <script.name> path:logger.log def.level:info def.task:validate.app def.message:<[message]>
                    - define registered <server.flag[<script.name>.apps.<[app-id]>.ast].exists>
                    - if ( not <[registered]> ):
                        - ~run <script.name> path:app.build save:build
                        - if ( not <entry[build].created_queue.determination.get[1]> ):
                            # |------- failed -------| #
                            - define message "'<[app-id]>' registration failed."
                            - ~run <script.name> path:logger.log def.level:error def.task:validate.app def.message:<[message]>
                            - determine false
                # |------- valid application -------| #
                - ~run <script.name> path:logger.log def.level:info def.task:build def.message:<server.flag[<script.name>.apps.<[app-id]>.ast].to_json>
                - ~run <script.name> path:validate.dependencies
                - ~run <script.name> path:validate.cache
                - if ( not <entry[build].created_queue.determination.exists> ):
                    - ~run <script.name> path:app.reset.ast
                - inject <script.name> path:app.reset.nav
                - define message "'<[app-id]>' validated."
                - ~run <script.name> path:logger.log def.level:info def.task:validate.app def.message:<[message]>
                - determine true
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                - determine false

        dependencies:
            #########################################################
            # | ---  |        validate dependencies        |  --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Required:  none                          --- | #
            # | ---                                           --- | #
            # | ---  Optional:  app-id                        --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Returns:  bool                           --- | #
            # | ---                                           --- | #
            #########################################################
            # | ---                                           --- | #
            # | ---  Run: true | Await: true | Inject: true   --- | #
            # | ---                                           --- | #
            #########################################################
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened].if_null[null]>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                # |------- define data -------| #
                - define plugins <script.data_key[data.config.dependencies.plugins]||null>
                - define loaded_plugins <list[]>
                # |------- plugin check -------| #
                - if not ( <[plugins].equals[null]> ):
                    - foreach <[plugins]> as:plugin:
                        - if ( <[plugin].equals[<empty>]> ) || ( <[plugin].equals[null]> ) || ( not <plugin[<[plugin]>].exists> ):
                            - foreach next
                        - else:
                            - define listed <server.plugins.if_null[<list[]>]>
                            - if ( <[listed]> contains <plugin[<[plugin]>]> ):
                                - define loaded_plugins:->:<[plugin]>
                            - else:
                                - define message "'<[plugin]>' could not be located. Skipping..."
                                - ~run <script.name> path:logger.log def.level:warning def.task:dependencies def.message:<[message]>
                # |------- store plugins -------| #
                - flag server <script.name>.dependencies.plugins:<[loaded_plugins]>
                - if ( <[loaded_plugins].any.if_null[false]> ) && ( <player.flag[<script.name>.debug]> ):
                    - define message "'<[loaded_plugins].size>' plugin(s) loaded."
                    - ~run <script.name> path:logger.log def.level:info def.task:dependencies def.message:<[message]>
                # |------- set permissions handler -------| #
                - foreach <server.flag[<script.name>.dependencies.plugins]> as:plugin:
                    - choose <[plugin]>:
                        - case default:
                            - foreach next
                        - case UltraPermissions:
                            - flag server <script.name>.permissions_handler:<[plugin]>
                        - case LuckPerms:
                            - flag server <script.name>.permissions_handler:<[plugin]>
                        - case Essentials:
                            - flag server <script.name>.permissions_handler:<[plugin]>
                    - foreach stop
                # |------- log permission handler -------| #
                - if ( <server.has_flag[<script.name>.permissions_handler]> ) && ( <player.flag[<script.name>.debug]> ):
                    - define message "perms-handler '<server.flag[<script.name>.permissions_handler]>' set."
                    - ~run <script.name> path:logger.log def.level:info def.task:dependencies def.message:<[message]>
                - else:
                    - define message "perms-handler could not be located."
                    - ~run <script.name> path:logger.log def.level:warning def.task:dependencies def.message:<[message]>
                # |------- container check -------| #
                - if ( not <player.has_flag[<script.name>.apps.<[app-id]>.inventories]> ):
                    - flag <player> <script.name>.apps.<[app-id]>.inventories:<list[<empty>]>
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."

        cache:
            ########################################################
            # | ---  |           validate cache           |  --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Required:  none                         --- | #
            # | ---                                          --- | #
            # | ---  Optional:  app-id                       --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Returns:  bool                          --- | #
            # | ---                                          --- | #
            ########################################################
            # | ---                                          --- | #
            # | ---  Run: true | Await: true | Inject: true  --- | #
            # | ---                                          --- | #
            ########################################################
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened]||null>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                # |------- gui data -------| #
                - ~run <script.name> path:app.get.ast save:ast
                - define ast <entry[ast].created_queue.determination.get[1]||null>
                - define blacklist <script.data_key[data.config.ids].get[blacklist]||<list[<empty>]>>
                - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                - if ( <[ast]> != null ):
                    - foreach <player.flag[<script.name>.apps.<[app-id]>.inventories]||<map[<empty>]>> key:gui-id as:properties:
                        - if ( not <[ast].deep_keys.separated_by[.].split[.].deduplicate.contains[<[gui-id]>]||true> ):
                            # |------- remove missing -------| #
                            - if ( not <[blacklist].contains[<[gui-id]>]> ):
                                - flag <player> <script.name>.apps.<[app-id]>.inventories:<-:<[gui-id]>
                                - define message "removed missing gui '<[gui-id]>'."
                                - ~run <script.name> path:logger.log def.level:warning def.task:validate.cache def.message:<[message]>
                        - if ( <[properties].keys> contains pages ):
                            # |------- reset properties -------| #
                            - foreach <list.pad_right[<[properties].get[pages]>]> as:page:
                                - note remove as:<player.name>_<[identifier]><[gui-id]>_<[loop_index]>
                            - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.index:!
                            - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.pages:!
                - else:
                    # |------- missing ast -------| #
                    - define message "'<[app-id]>' has not been built."
                    - ~run <script.name> path:logger.log def.level:error def.task:validate.cache def.message:<[message]>
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."

        gui:
            ##########################################################
            # | ---  |             validate gui             |  --- | #
            ##########################################################
            # | ---                                            --- | #
            # | ---  Required:  gui-id                         --- | #
            # | ---                                            --- | #
            # | ---  Optional:  app-id | title | list | fill   --- | #
            # | ---                                            --- | #
            ##########################################################
            # | ---                                            --- | #
            # | ---  Returns:  inventory tag | bool            --- | #
            # | ---                                            --- | #
            ##########################################################
            # | ---                                            --- | #
            # | ---  Run: true | Await: true | Inject: false   --- | #
            # | ---                                            --- | #
            ##########################################################
            - if ( not <[app-id].exists> ):
                - define app-id <player.flag[<script.name>.opened]||null>
            # |------- parameter check -------| #
            - if ( <[app-id]> != null ):
                - if ( <[gui-id]||null> != null ):
                    # |------- gui data -------| #
                    - ~run <script.name> path:app.get.ast save:ast
                    - define ast <entry[ast].created_queue.determination.get[1]||null>
                    - define built <[ast].deep_keys.separated_by[.].split[.].deduplicate||null>
                    - define blacklist <script.data_key[data.config.ids].get[blacklist]||<list[<empty>]>>
                    # |------- parse ast -------| #
                    - if ( not <player.flag[<script.name>.apps.<[app-id]>.inventories].contains[<[gui-id]>]||false> ):
                        - if ( <[ast]> != null ):
                            - if ( <[built]> != null ):
                                # |------- validate gui-id -------| #
                                - if ( not <[built].contains[<[gui-id]>]> ) && ( not <[blacklist].contains[<[gui-id]>]> ):
                                    # |------- missing gui-id -------| #
                                    - define message "could not locate '<[gui-id]>' in abstract syntax tree. Ensure '<[gui-id]>' inventory is configured properly."
                                    - ~run <script.name> path:logger.log def.level:error def.task:validate.gui def.message:<[message]>
                                    - determine false
                                - else:
                                    - definemap properties:
                                        title: <[title]||null>
                                    # |------- cache gui-id -------| #
                                    - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>:<[properties]>
                                    - define message "'<[gui-id]>' cached successfully."
                                    - ~run <script.name> path:logger.log def.level:info def.task:validate.gui def.message:<[message]>
                        - else:
                            # |------- missing ast -------| #
                            - define message "'<[gui-id]>' has not been built."
                            - ~run <script.name> path:logger.log def.level:error def.task:validate.gui def.message:<[message]>
                            - determine false
                    # |------- instantiate inventory -------| #
                    - define identifier <script.parsed_key[data.config.ids.valid-gui]>
                    - choose <[gui-id]>:
                        - case dialog select:
                            # |------- custom -------| #
                            - if ( not <[built].contains[<[gui-id]>]> ):
                                - define inventory <inventory[<[identifier].replace_text[<[app-id]>].with[<script.name>]><[gui-id]>]||null>
                            - else:
                                - define inventory <inventory[<[identifier].replace_text[<[app-id]>].with[<script.name>]><[gui-id]>]||null>
                                - if ( <[inventory]> != null ):
                                    - if ( <[gui-id]> == select ) && ( <[list].id_type.exists> ):
                                        - define inventory <[list]>
                                        - define list skip
                                    - else:
                                        - define custom <inventory[<[identifier]><[gui-id]>]||null>
                                        - if ( <[custom]> != null ):
                                            - adjust <[inventory]> contents:<[custom].list_contents>
                        - default:
                            # |------- default -------| #
                            - define inventory <inventory[<[identifier]><[gui-id]>]||null>
                    # |------- adjust properties -------| #
                    - if ( <[inventory]> != null ):
                        - define properties <player.flag[<script.name>.apps.<[app-id]>.inventories].get[<[gui-id]>]||null>
                        - if ( <[list]||null> != skip ):
                            # |------- title -------| #
                            - if ( <[title]||null> != null ):
                                - adjust <[inventory]> title:<[title]>
                                - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.title:<[title]||null>
                            - else if ( <[properties].get[title]||null> != null ):
                                - adjust <[inventory]> title:<[properties].get[title]>
                            # |------- pages -------| #
                            - if ( <[list]||null> != null || <[fill]||null> != null ) && ( <[list]||null> != next ) && ( <[list]||null> != previous ):
                                - define slots <[inventory].list_contents.find_all_matches[air]>
                                - if ( <[slots].size> != 0 ):
                                    - if ( not <[list].is_empty||true> ):
                                        # |------- reset cached -------| #
                                        - foreach <list.pad_right[<[properties].get[pages]||0>]> as:page:
                                            - note remove as:<player.name>_<[identifier]><[gui-id]>_<[loop_index]>
                                        # |------- build pages -------| #
                                        - define pages <[list].sub_lists[<[slots].size>]>
                                        - define last <[pages].last>
                                        - if ( <[last].size> < <[slots].size> ):
                                            - define pages:<-:<[last]>
                                            - define last <[last].pad_right[<[slots].size>]>
                                            - if ( <[fill]||null> != null ):
                                                - define last <[last].replace[<empty>].with[<[fill]>]>
                                            - define pages:->:<[last]>
                                        # |------- cache pages -------| #
                                        - foreach <[pages]> as:page:
                                            - define page-id <player.name>_<[identifier]><[gui-id]>_<[loop_index]>
                                            - note <[inventory]> as:<[page-id]>
                                            - foreach <[slots].map_with[<[page]>]> key:slot as:item:
                                                - inventory set d:<inventory[<[page-id]>]> o:<[item]> slot:<[slot]>
                                        - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.pages:<[pages].size>
                                    - else if ( <[fill]||null> != null ) && ( <[list].is_empty||true> ):
                                        # |------- empty filled list -------| #
                                        - define page-id <player.name>_<[identifier]><[gui-id]>_1
                                        - note <[inventory]> as:<[page-id]>
                                        - foreach <[slots]> as:slot:
                                            - inventory set d:<inventory[<[page-id]>]> o:<[fill]> slot:<[slot]>
                                        - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.pages:1
                                - else:
                                    # |------- null slots -------| #
                                    - define message "inventory '<[identifier]><[gui-id]>' does not contain any empty slots."
                                    - ~run <script.name> path:logger.log def.level:warning def.task:validate.gui def.message:<[message]>
                            - define properties <player.flag[<script.name>.apps.<[app-id]>.inventories].get[<[gui-id]>]||null>
                            - if ( <[properties].get[pages]||null> != null ):
                                - define index <[properties].get[index]||1>
                                - define pages <[properties].get[pages]||1>
                                - if ( <[list]||null> == next ):
                                    - if ( <[index].add[1]> > <[pages]> ):
                                        - define index <[pages]>
                                    - else:
                                        - define index:++
                                - else if ( <[list]||null> == previous ):
                                    - if ( <[index].sub[1]> >= 1 ):
                                        - define index:--
                                - if ( <inventory[<player.name>_<[identifier]><[gui-id]>_<[index]>]||null> != null ):
                                    - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.index:<[index]>
                                    - define inventory <inventory[<player.name>_<[identifier]><[gui-id]>_<[index]>]>
                                - else:
                                    - if ( <[index]> != 1 ):
                                        - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.index:<[index].sub[1]>
                                        - define inventory <inventory[<player.name>_<[identifier]><[gui-id]>_<[index].sub[1]>]>
                                    - else:
                                        - flag <player> <script.name>.apps.<[app-id]>.inventories.<[gui-id]>.index:1
                                        - define inventory <inventory[<player.name>_<[identifier]><[gui-id]>_1]>
                        # |------- success -------| #
                        - determine <[inventory]>
                    - else:
                        # |------- missing script -------| #
                        - define message "inventory script '<[identifier]><[gui-id]>' could not be instantiated."
                        - ~run <script.name> path:logger.log def.level:error def.task:validate.gui def.message:<[message]>
                        - determine false
                - else:
                    # |------- missing parameter gui-id -------| #
                    - define message "validation failed. Missing required parameter 'gui-id'."
                    - ~run <script.name> path:logger.log def.level:error def.task:validate.gui def.message:<[message]>
                    - determine false
            - else:
                # |------- missing parameter 'app-id' -------| #
                - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
                - determine false



# | ------------------------------------------------------------------------------------------------------------------------------ | #



    open:
        ########################################################
        # | ---  |              open gui              |  --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Required:  none                         --- | #
        # | ---                                          --- | #
        # | ---  Optional:  app-id | gui-id | title      --- | #
        # | ---                                          --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Returns:  bool                          --- | #
        # | ---                                          --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Run: true | Await: true | Inject: false --- | #
        # | ---                                          --- | #
        ########################################################
        # |------- application data -------| #
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[<script.name>.opened]||null>
        # |------- get data -------| #
        - ~run <script.name> path:validate.id def.gui-id:<[gui-id]||null> def.ignore:false save:gui-id
        - define gui-id <entry[gui-id].created_queue.determination.get[1]||null>
        - ~run <script.name> path:app.get.root def.gui-id:<[gui-id]||null> save:root
        - define root <entry[root].created_queue.determination.get[1]||null>
        - define blacklist <script.data_key[data.config.ids].get[blacklist]||<list[<empty>]>>
        # |------- nav data -------| #
        - define current <player.flag[<script.name>.current]||<[root]>>
        - define next <player.flag[<script.name>.next]||<list[<empty>]>>
        - define previous <player.flag[<script.name>.previous]||<list[<empty>]>>
        # |------- parse gui-id -------| #
        - if ( <[app-id]> != null ):
            ########################################
            # |------- gui-id of type str -------| #
            ########################################
            - if ( not <[gui-id].keys.size.exists> ):
                - if ( <[gui-id]> == null ):
                    # |------- default -------| #
                    - define target <[root]>
                - else:
                    - define target <[gui-id]>
                # |------- validation check -------| #
                - ~run <script.name> path:validate.gui def.gui-id:<[target]> def.page:<[page]||null> def.title:<[title]||null> def.list:<[list]||null> def.fill:<[fill]||null> save:validated
                - define inventory <entry[validated].created_queue.determination.get[1]>
                - if ( <[inventory]> != false ):
                    # |------- validate cache -------| #
                    - if ( <[current]> == <[root]> ) && ( <[target]> != <[next].get[1]||null> ):
                        - flag <player> <script.name>.next:!|:<list[<empty>]>
                        - define next <player.flag[<script.name>.next]>
                    - if ( <[current]> != <[root]> ):
                        - if ( not <[next].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                            - flag <player> <script.name>.next:->:<[current]>
                    - if ( <[target]> != <[root]> ) && ( <[current]> != <[target]> ):
                        - if ( not <[next].contains[<[target]>]> ) && ( not <[blacklist].contains[<[target]>]> ):
                            - flag <player> <script.name>.next:->:<[target]>
                        - if ( not <[previous].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                            - flag <player> <script.name>.previous:->:<[current]>
                    # |------- validate next -------| #
                    - define next <player.flag[<script.name>.next]||<list[<empty>]>>
                    - if ( <[next].any> ):
                        # |------- lineage data -------| #
                        - ~run <script.name> path:app.get.parent def.gui-id:<[target]> save:parent
                        - ~run <script.name> path:app.get.siblings def.gui-id:<[target]> save:siblings
                        - define parent <entry[parent].created_queue.determination.get[1]>
                        - define siblings <entry[siblings].created_queue.determination.get[1]>
                        - define last <[next].last||null>
                        # |------- check lineage -------| #
                        - if ( <[siblings].any||false> ) && ( <[parent]> != <[root]> ) && ( <[next]> contains <[last]> ):
                            - foreach <[siblings]> as:sibling:
                                - if ( <[next]> contains <[sibling]> ):
                                    - flag <player> <script.name>.next:<-:<[sibling]>
                                    - define next:<-:<[sibling]>
                    - if ( <[reset]||false> ):
                        # |------- reset next -------| #
                        - define current-index <[next].find[<[target]>]>
                        - define next-index <[current-index].add[1]>
                        - define last-index <[next].find[<[next].last||<[current-index]>>]>
                        - if ( <[next].size> > 1 ) && ( <[last-index]> > <[current-index]> ):
                            - flag player <script.name>.next:<[next].remove[<[next-index]>].to[<[last-index]>]||<[next]>>
                    # |------- open gui-id -------| #
                    - flag <player> <script.name>.current:<[target]>
                    - playsound <player> sound:<script.data_key[data.config.sounds].get[left-click-button]> pitch:1
                    - inventory open destination:<[inventory]>
                    - define message "'<[target]>' opened."
                    - ~run <script.name> path:logger.log def.level:info def.task:open def.message:<[message]>
                    # |------- debug cache -------| #
                    - if ( <player.flag[<script.name>.debug]> ):
                        - narrate "<&nl>Current: <player.flag[<script.name>.current]><&nl>Next: <player.flag[<script.name>.next]><&nl>Previous: <player.flag[<script.name>.previous]><&nl>"
                    # |------- success -------| #
                    - determine true
                - else:
                    # |------- pass -------| #
                    - determine false
            ########################################
            # |------- gui-id of type map -------| #
            ########################################
            - else if ( <[gui-id].keys.size.exists> ):
                # |------- cache data -------| #
                - define cache-id <[gui-id].get[1]||null>
                - define target <[gui-id].get[2]||null>
                - define cached <[gui-id].get[3]||null>
                - define iterate <[gui-id].get[4]||false>
                - choose <[cache-id]>:
                    - default:
                        # |------- invalid cache-id -------| #
                        - define message "cache-id '<[cache-id]>' is invalid."
                        - ~run <script.name> path:logger.log def.level:error def.task:open def.message:<[message]>
                        - determine false
                    - case next:
                        # |------- parse next -------| #
                        - if ( not <list[<[target]>|<[cached]>|<[iterate]>].contains[null]> ):
                            # |------- validation check -------| #
                            - ~run <script.name> path:validate.gui def.gui-id:<[target]> def.page:<[page]||null> def.title:<[title]||null> def.list:<[list]||null> def.fill:<[fill]||null> save:validated
                            - define inventory <entry[validated].created_queue.determination.get[1]>
                            - if ( <[inventory]> != false ):
                                # |------- validate cache -------| #
                                - if ( not <[previous].contains[<[current]>]> ):
                                    - flag <player> <script.name>.previous:->:<[current]>
                                - if ( <[iterate]> ):
                                    - foreach <[cached]> as:id:
                                        - if ( not <[previous].contains[<[id]>]> ):
                                            - flag <player> <script.name>.previous:->:<[id]>
                                        - else:
                                            - define message "'<[id]>' already found in previous cache."
                                            - ~run <script.name> path:logger.log def.level:warning def.task:next def.message:<[message]>
                                - if ( <[reset]||false> ):
                                    # |------- reset next -------| #
                                    - define next <player.flag[<script.name>.next]||<list[<empty>]>>
                                    - define current-index <[next].find[<[target]>]>
                                    - define next-index <[current-index].add[1]>
                                    - define last-index <[next].find[<[next].last||<[current-index]>>]>
                                    - if ( <[next].size> > 1 ) && ( <[last-index]> > <[current-index]> ):
                                        - flag player <script.name>.next:<[next].remove[<[next-index]>].to[<[last-index]>]||null>
                                # |------- open next -------| #
                                - flag <player> <script.name>.current:<[target]>
                                - playsound <player> sound:<script.data_key[data.config.sounds].get[left-click-button]> pitch:1
                                - inventory open destination:<[inventory]>
                                - define message "'<[target]>' opened."
                                - ~run <script.name> path:logger.log def.level:info def.task:next def.message:<[message]>
                                # |------- debug cache -------| #
                                - if ( <player.flag[<script.name>.debug]> ):
                                    - narrate "<&nl>Current: <player.flag[<script.name>.current]><&nl>Next: <player.flag[<script.name>.next]><&nl>Previous: <player.flag[<script.name>.previous]><&nl>"
                                # |------- success -------| #
                                - determine true
                            - else:
                                # |------- invalid target -------| #
                                - determine false
                        - else:
                            # |------- empty cache -------| #
                            - determine false
                    - case previous:
                        # |------- parse previous -------| #
                        - if ( <[current]> != <[root]> ) && ( not <list[<[target]>|<[cached]>].contains[null]> ):
                            # |------- validation check -------| #
                            - ~run <script.name> path:validate.gui def.gui-id:<[target]> def.page:<[page]||null> def.title:<[title]||null> def.list:<[list]||null> def.fill:<[fill]||null> save:validated
                            - define inventory <entry[validated].created_queue.determination.get[1]>
                            - if ( <[inventory]> != false ):
                                # |------- validate cache -------| #
                                - flag <player> <script.name>.previous:!|:<[cached]>
                                - if ( not <player.flag[<script.name>.next].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                                    - flag <player> <script.name>.next:->:<[current]>
                                - if ( <[reset]||false> ):
                                    # |------- reset next -------| #
                                    - define next <player.flag[<script.name>.next]||<list[<empty>]>>
                                    - define current-index <[next].find[<[target]>]>
                                    - define next-index <[current-index].add[1]>
                                    - define last-index <[next].find[<[next].last||<[current-index]>>]>
                                    - if ( <[next].size> > 1 ) && ( <[last-index]> > <[current-index]> ):
                                        - flag player <script.name>.next:<[next].remove[<[next-index]>].to[<[last-index]>]||null>
                                # |------- open previous -------| #
                                - flag <player> <script.name>.current:<[target]>
                                - playsound <player> sound:<script.data_key[data.config.sounds].get[left-click-button]> pitch:1
                                - inventory open destination:<[inventory]>
                                - define message "'<[target]>' opened."
                                - ~run <script.name> path:logger.log def.level:info def.task:prev def.message:<[message]>
                                # |------- debug cache -------| #
                                - if ( <player.flag[<script.name>.debug]> ):
                                    - narrate "<&nl>Current: <player.flag[<script.name>.current]><&nl>Next: <player.flag[<script.name>.next]><&nl>Previous: <player.flag[<script.name>.previous]><&nl>"
                                # |------- success -------| #
                                - determine true
                            - else:
                                # |------- invalid target -------| #
                                - determine false
                        - else if ( <[current]> == <[root]> ) && ( <[cached].is_empty> ):
                            # |------- close app -------| #
                            - inventory close
                            - playsound <player> sound:<script.data_key[data.config.sounds].get[left-click-button]> pitch:1
                            - flag <player> <script.name>.next:<list[<empty>]>
                            - flag <player> <script.name>.current:null
                            - define message "'<[app-id]>' closed."
                            - ~run <script.name> path:logger.log def.level:info def.task:prev def.message:<[message]>
                            # |------- debug cache -------| #
                            - if ( <player.flag[<script.name>.debug]> ):
                                - narrate "<&nl>Current: <player.flag[<script.name>.current]><&nl>Next: <player.flag[<script.name>.next]><&nl>Previous: <player.flag[<script.name>.previous]><&nl>"
                            - determine false
                        - else:
                            # |------- invalid cache -------| #
                            - define message "received cache-data '<[gui-id]>' is invalid. A critical error has occurred."
                            - ~run <script.name> path:logger.log def.level:error def.task:prev def.message:<[message]>
                            - determine false
            - else:
                # |------- invalid gui-id -------| #
                - define message "gui-id '<[gui-id]>' is invalid."
                - ~run <script.name> path:logger.log def.level:error def.task:open def.message:<[message]>
                - determine false
        - else:
            # |------- missing parameter 'app-id' -------| #
            - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."
            - determine false


    select:
        ################################################################
        # | ---  |               open selection               |  --- | #
        ################################################################
        # | ---                                                  --- | #
        # | ---  Required:  select_list                          --- | #
        # | ---                                                  --- | #
        # | ---  Optional:  app-id | select_title                --- | #
        # | ---                                                  --- | #
        ################################################################
        # | ---                                                  --- | #
        # | ---  Returns:  none                                  --- | #
        # | ---                                                  --- | #
        ################################################################
        # | ---                                                  --- | #
        # | ---  Run: false | Await: false | Inject: true        --- | #
        # | ---                                                  --- | #
        ################################################################
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[<script.name>.opened].if_null[null]>
        - if ( <[app-id]> != null ):
            # |------- reset flags -------| #
            - flag <player> <script.name>.awaiting_select:true
            - flag <player> <script.name>.select:!
            # |------- open dialog inventory -------| #
            - ~run <script.name> path:open def.gui-id:select def.title:<[select_title]||null> def.list:<[select_list]||null> save:open
            - if ( <entry[open].created_queue.determination.get[1]||false> ):
                # |------- await dialog -------| #
                - waituntil <player.has_flag[<script.name>.select]> rate:1t max:60s
                - flag <player> <script.name>.awaiting_select:!
                - if ( not <player.has_flag[<script.name>.select]> ):
                    # |------- dialog timeout -------| #
                    - if ( <player.flag[<script.name>.debug]> ):
                        - define message "task timed-out."
                        - ~run <script.name> path:logger.log def.level:info def.task:select def.message:<[message]>
                - else:
                    - if ( <player.flag[<script.name>.debug]> ):
                        - define message "'<player.flag[<script.name>.select]>' received."
                        - ~run <script.name> path:logger.log def.level:info def.task:select def.message:<[message]>
        - else:
            # |------- missing parameter 'app-id' -------| #
            - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."


    dialog:
        ###########################################################
        # | ---  |              open dialog              |  --- | #
        ###########################################################
        # | ---                                             --- | #
        # | ---  Required:  none                            --- | #
        # | ---                                             --- | #
        # | ---  Optional:  app-id | dialog_title           --- | #
        # | ---                                             --- | #
        ###########################################################
        # | ---                                             --- | #
        # | ---  Returns:  none                             --- | #
        # | ---                                             --- | #
        ###########################################################
        # | ---                                             --- | #
        # | ---  Run: false | Await: false | Inject: true   --- | #
        # | ---                                             --- | #
        ###########################################################
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[<script.name>.opened].if_null[null]>
        - if ( <[app-id]> != null ):
            # |------- reset flags -------| #
            - flag <player> <script.name>.awaiting_dialog:true
            - flag <player> <script.name>.dialog:!
            # |------- open dialog inventory -------| #
            - ~run <script.name> path:open def.gui-id:dialog def.title:<[dialog_title]||null> save:open
            - if ( <entry[open].created_queue.determination.get[1]||false> ):
                # |------- await dialog -------| #
                - waituntil <player.has_flag[<script.name>.dialog]> rate:1t max:60s
                - flag <player> <script.name>.awaiting_dialog:!
                - if ( not <player.has_flag[<script.name>.dialog]> ):
                    # |------- dialog timeout -------| #
                    - if ( <player.flag[<script.name>.debug]> ):
                        - define message "task timed-out."
                        - ~run <script.name> path:logger.log def.level:info def.task:dialog def.message:<[message]>
                - else:
                    - if ( <player.flag[<script.name>.debug]> ):
                        - define message "'<player.flag[<script.name>.dialog]>' received."
                        - ~run <script.name> path:logger.log def.level:info def.task:dialog def.message:<[message]>
        - else:
            # |------- missing parameter 'app-id' -------| #
            - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."


    input:
        ##########################################################################
        # | ---  |                      open input                      |  --- | #
        ##########################################################################
        # | ---                                                            --- | #
        # | ---  Required:  input_title | input_subtitle | input_bossbar   --- | #
        # | ---                                                            --- | #
        # | ---  Optional:  app-id                                         --- | #
        # | ---                                                            --- | #
        ##########################################################################
        # | ---                                                            --- | #
        # | ---  Returns:  none                                            --- | #
        # | ---                                                            --- | #
        ##########################################################################
        # | ---                                                            --- | #
        # | ---  Run: false | Await: false | Inject: true                  --- | #
        # | ---                                                            --- | #
        ##########################################################################
        - ratelimit <player> 1t
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[<script.name>.opened]||null>
        - if ( <[app-id]> != null ):
            # |------- interrupt discordSRV -------| #
            - define discordSRV <server.plugins.contains[<plugin[DiscordSRV]>]||false>
            - define perms_handler <server.flag[<script.name>.permissions_handler]||null>
            - if ( <[DiscordSRV]> ):
                - choose <[perms_handler]>:
                    - case UltraPermissions:
                        - execute as_server "upc AddPlayerPermission <player.name> -discordsrv.player" silent
                    - case LuckPerms:
                        - narrate placeholder
                    - case Essentials:
                        - narrate placeholder
            # |------- input data -------| #
            - define timeout <script.data_key[data.config.dialog.input-timeout]||60s>
            - if ( <[timeout].is_integer> ):
                - define timeout <duration[<[timeout]>s]||null>
            - else:
                - define timeout <duration[<[timeout]>]||null>
            - if ( <[timeout]> != null ):
                # |------- close gui -------| #
                - inventory close
                # |------- reset flags -------| #
                - flag <player> <script.name>.awaiting_input:!
                - flag <player> <script.name>.input:!
                # |------- set flags -------| #
                - flag <player> <script.name>.awaiting_input:true
                # |------- loop data -------| #
                - define count <[timeout].in_seconds>
                - define ticks 0
                # |------- display -------| #
                - title title:<[input_title]> subtitle:<[input_subtitle]> stay:<[timeout]> fade_in:1s fade_out:1s targets:<player>
                - bossbar create id:awaiting title:<&b><&l><[input_bossbar]><&sp><&b><&l>-<&sp><&a><&l><[count]><&sp><&f><&l>seconds progress:0 color:red
                # |------- awaiting input -------| #
                - while ( <[count]> >= 1 ):
                    - define awaiting <player.flag[<script.name>.awaiting_input]||false>
                    - if ( <[ticks]> == 20 ):
                        # |------- adjust count -------| #
                        - bossbar update id:awaiting title:<&b><&l><[input_bossbar]><&sp><&b><&l>-<&sp><&a><&l><[count]><&sp><&f><&l>seconds progress:0 color:red
                        - define count:--
                        - define ticks 0
                    - if ( <[awaiting]> ) && ( <[loop_index]> <= <[timeout].in_seconds.mul[4]> ):
                        # |------- input check -------| #
                        - wait 5t
                        - define ticks:+:5
                        - while next
                    - else:
                        # |------- received input -------| #
                        - if ( <player.has_flag[<script.name>.awaiting_input]> ):
                            - flag <player> <script.name>.awaiting_input:!
                            - wait 1s
                            - bossbar update id:awaiting title:<&b><&l><[input_bossbar]><&sp><&b><&l>-<&sp><&f><[count]><&sp><&f><&l>seconds progress:0 color:red
                            - wait 1s
                        # |------- cleanup display -------| #
                        - bossbar remove id:awaiting
                        - execute as_server "title <player.name> clear" silent
                        # |------- resume discordSRV -------| #
                        - if ( <[discordSRV]> ):
                            - choose <[perms_handler]>:
                                - case UltraPermissions:
                                    - execute as_server "upc RemovePlayerPermission <player.name> discordsrv.player" silent
                                - case LuckPerms:
                                    - narrate placeholder
                                - case Essentials:
                                    - narrate placeholder
                        - while stop
                # |------- validate input -------| #
                - if ( <player.has_flag[<script.name>.input]> ):
                    - define keywords <script.data_key[data.config.dialog.cancel-keywords]||<list[<empty>]>>
                    - if ( not <[keywords].contains[<player.flag[<script.name>.input]>]> ):
                        # |------- success -------| #
                        - if ( <player.flag[<script.name>.debug]> ):
                            - define message "'<player.flag[<script.name>.input]>' received."
                            - ~run <script.name> path:logger.log def.level:info def.task:input def.message:<[message]>
                    - else:
                        # |------- input cancel -------| #
                        - flag <player> <script.name>.input:!
                        - if ( <player.flag[<script.name>.debug]> ):
                            - define message "task cancelled."
                            - ~run <script.name> path:logger.log def.level:info def.task:input def.message:<[message]>
                - else:
                    # |------- input timeout -------| #
                    - if ( <player.flag[<script.name>.debug]> ):
                        - define message "task timed-out."
                        - ~run <script.name> path:logger.log def.level:info def.task:input def.message:<[message]>
            - else:
                # |------- invalid timeout -------| #
                - define message "'input-timeout' is not a valid integer."
                - ~run <script.name> path:logger.log def.level:error def.task:input def.message:<[message]>
        - else:
            # |------- missing parameter 'app-id' -------| #
            - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."


    cancel:
        ########################################################
        # | ---  |               cancel               |  --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Required:  none                         --- | #
        # | ---                                          --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Returns:  none                          --- | #
        # | ---                                          --- | #
        ########################################################
        # | ---                                          --- | #
        # | ---  Run: true | Await: true | Inject: true  --- | #
        # | ---                                          --- | #
        ########################################################
        # |------- event data -------| #
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[<script.name>.opened].if_null[null]>
        - define prefix <script.data_key[data.config.prefixes.main].parse_color.strip_color>
        - define discordSRV <server.plugins.contains[<plugin[DiscordSRV]>]||false>
        - define perms_handler <server.flag[<script.name>.permissions_handler].if_null[null]>
        # |------- reset flags -------| #
        - flag <player> <script.name>.select:!
        - flag <player> <script.name>.dialog:!
        - flag <player> <script.name>.input:!
        - if ( <[app-id]> != null ):
            # |------- flag check -------| #
            - if ( <player.has_flag[<script.name>.awaiting_select]> ):
                # |------- cancel selection -------| #
                - flag <player> <script.name>.awaiting_select:!
            - if ( <player.has_flag[<script.name>.awaiting_dialog]> ):
                # |------- cancel dialog -------| #
                - flag <player> <script.name>.awaiting_dialog:!
            - if ( <player.has_flag[<script.name>.awaiting_input]> ):
                # |------- cancel input -------| #
                - flag <player> <script.name>.awaiting_input:!
                # |------- resume discordSRV -------| #
                - if ( <[discordSRV]> ):
                    - choose <[perms_handler]>:
                        - case UltraPermissions:
                            - execute as_server "upc RemovePlayerPermission <player.name> discordsrv.player" silent
                        - case LuckPerms:
                            - narrate placeholder
                        - case Essentials:
                            - narrate placeholder
                # |------- cleanup instructions -------| #
                - bossbar remove id:awaiting
            # |------- cancel queues -------| #
            - foreach <util.queues.exclude[<queue>]> as:queue:
                - if ( <[queue].script.contains_text[<script.name>]> ) || ( <[queue].script.contains_text[<[app-id]>]> ):
                    - if ( <[queue].player> == <player> ) && ( <[queue].is_valid> ):
                        - queue <[queue]> clear
                        - define message "'<[queue].id.before_last[_]>' cancelled."
                        - ~run <script.name> path:logger.log def.level:info def.task:cancel def.message:<[message]>
        - else:
            # |------- missing parameter 'app-id' -------| #
            - ~debug error "couldn't locate 'app-id'. Missing 'opened' flag."



# | ----------------------------------------------  GUI MANAGER | INVENTORIES  ---------------------------------------------- | #



gui_manager_gui_dialog:
    ####################################################
    # | ---  |       default dialog gui       |  --- | #
    ####################################################
    type: inventory
    debug: false
    inventory: CHEST
    title: Dialog Title Placeholder
    gui: true
    definitions:
        edge-fill: <item[gray_stained_glass_pane].with[display=<&d> <empty>]>
        green-fill: <item[green_stained_glass_pane].with[display=<&d> <empty>]>
        red-fill: <item[red_stained_glass_pane].with[display=<&d> <empty>]>
        confirm-dialog: <item[player_head].with_flag[gui-button:confirm].with[display=<&a><&l>Confirm;skull_skin=04049c90-d3e9-4621-9caf-0000aaa21774|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDMxMmNhNDYzMmRlZjVmZmFmMmViMGQ5ZDdjYzdiNTVhNTBjNGUzOTIwZDkwMzcyYWFiMTQwNzgxZjVkZmJjNCJ9fX0=]>
        deny-dialog: <item[player_head].with_flag[gui-button:deny].with[display=<&c><&l>Deny;skull_skin=04049c90-d3e9-4621-9caf-00000aaa9348|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTdmOWM2ZmVmMmFkOTZiM2E1NDY1NjQyYmE5NTQ2NzFiZTFjNDU0M2UyZTI1ZTU2YWVmMGE0N2Q1ZjFmIn19fQ==]>
    slots:
        - [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill]
        - [edge-fill] [red-fill] [red-fill] [red-fill] [edge-fill] [green-fill] [green-fill] [green-fill] [edge-fill]
        - [edge-fill] [red-fill] [deny-dialog] [red-fill] [edge-fill] [green-fill] [confirm-dialog] [green-fill] [edge-fill]
        - [edge-fill] [red-fill] [red-fill] [red-fill] [edge-fill] [green-fill] [green-fill] [green-fill] [edge-fill]
        - [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill]



# | ------------------------------------------------------------------------------------------------------------------------------ | #



gui_manager_gui_select:
    ####################################################
    # | ---  |       default select gui       |  --- | #
    ####################################################
    type: inventory
    debug: false
    inventory: CHEST
    title: Select Title Placeholder
    gui: true
    definitions:
        edge-fill: <item[gray_stained_glass_pane].with[display=<&d> <empty>]>
        green-fill: <item[green_stained_glass_pane].with[display=<&d> <empty>]>
        red-fill: <item[red_stained_glass_pane].with[display=<&d> <empty>]>
    slots:
        - [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill]
        - [edge-fill] [] [] [] [] [] [] [] [edge-fill]
        - [edge-fill] [] [] [] [] [] [] [] [edge-fill]
        - [edge-fill] [] [] [] [] [] [] [] [edge-fill]
        - [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill] [edge-fill]



# | ------------------------------------------------------------------------------------------------------------------------------ | #


