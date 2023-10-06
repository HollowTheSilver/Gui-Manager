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
# @date                 9/26/2023
# @script-version       DEV-1.0.9
# @denizen-build-1.2.8  REL-1794
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
        author: HollowTheSilver
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
            dependencies:
                # |--------------------------------------------------------------| #
                # | ---   These dependencies are treated as priorty lists    --- | #
                # | ---   that are checked when the gui manager utilizes a   --- | #
                # | ---   dependency throughout run time. The data is read   --- | #
                # | ---   in descending order, so this means that in cases   --- | #
                # | ---   where only one element of a specific category is   --- | #
                # | ---   required, such as a permissions plugin, the first  --- | #
                # | ---   element found from the top will be chosen. You     --- | #
                # | ---   should consider this when listing related plugins. --- | #
                # |--------------------------------------------------------------| #
                plugins:
                    # | ---  plugin name  --- | #
                    - UltraPermissions
                    - LuckPerms
                    - Essentials
            log:
                dir: plugins/Denizen/data/logs/gui_manager/
                max: 10



# | ----------------------------------------------  GUI MANAGER | EVENTS  ---------------------------------------------- | #



    events:
        ##############################################
        # | ---  |      manager events      |  --- | #
        ##############################################
        on script generates error:
            - if ( <context.message.contains_text[testing/debugging<&sp>only]> ):
                # |------- suppress list_flags warning -------| #
                - determine cancelled



# | ----------------------------------------------  GUI MANAGER | TASKS  ---------------------------------------------- | #



gui_manager_init:
    #########################################################
    # | ---  |         initialize app task         |  --- | #
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
    type: task
    debug: false
    definitions: app-id
    script:
        - waituntil <util.queues.exclude[<queue>].filter_tag[<[filter_value].script.name.equals[<script.name>].and[<[filter_value].player.equals[<player>]>].and[<[filter_value].state.equals[running]>]>].is_empty> max:10t rate:1t
        # |------- parameter check -------| #
        - if not ( <player.has_flag[gui_manager.debug]> ):
            - flag <player> gui_manager.debug:false
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "initialization failed. Parameter 'app-id' missing."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        # |------- initialize -------| #
        - if ( <util.random.int[0].to[100]> == 1 ):
            - inject gui_manager_purge_logs
        - flag <player> gui_manager.opened:<[app-id]>
        - inject gui_manager_reset_cache
        - define message "<[log_prefix]> - init() -<&gt> '<[app-id]>' initialized."
        - if ( <player.flag[gui_manager.debug]> ):
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>
        - determine true



gui_manager_open:
    ###############################################################################
    # | ---  |                       open gui task                       |  --- | #
    ###############################################################################
    # | ---                                                                 --- | #
    # | ---  Required:  gui-id                                              --- | #
    # | ---                                                                 --- | #
    # | ---  Optional:  app-id | gui-id(s) | page | index | ignore | build  --- | #
    # | ---             validate | title | contents | fill | cache-reset    --- | #
    # | ---                                                                 --- | #
    # | ---                                                                 --- | #
    ###############################################################################
    # | ---                                                                 --- | #
    # | ---  Returns:  bool                                                 --- | #
    # | ---                                                                 --- | #
    ###############################################################################
    # | ---                                                                 --- | #
    # | ---  Run: true | Await: true | Inject: false                        --- | #
    # | ---                                                                 --- | #
    ###############################################################################
    type: task
    debug: false
    definitions: app-id | gui-id | page | index | title | contents | fill | ignore | auto-title | validate | cache-reset
    script:
        - waituntil <util.queues.exclude[<queue>].filter_tag[<[filter_value].script.name.equals[<script.name>].and[<[filter_value].player.equals[<player>]>].and[<[filter_value].state.equals[running]>]>].is_empty> max:10t rate:1t
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        # |------- gui data -------| #
        - ~run gui_manager_get_root def.gui-id:<[gui-id]||null> def.ignore:<[ignore]||false> save:root
        - define root <entry[root].created_queue.determination.get[1]||null>
        - define identifier <script[gui_manager].parsed_key[data.config.ids.valid-gui]>
        # |------- nav data -------| #
        - define current <player.flag[gui_manager.current]||<[root]>>
        - define next-cache <player.flag[gui_manager.next]||<list>>
        - define previous-cache <player.flag[gui_manager.previous]||<list>>
        - define blacklist <player.flag[gui_manager.apps.<[app-id]>.blacklist]>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        # |------- multi check -------| #
        - if ( <[gui-id].any.exists> ):
            - goto skip-open
        # |------- parse page-id -------| #
        - if ( <[page]||null> != null ):
            - define parsable <[page].replace_text[regex:<&sp>|-].with[_]||<[page]>>
            - define parsed <[parsable].split[_]||<list>>
            - if ( <[parsed].last.is_integer> ):
                - define page-index <[parsed].last>
                - define page <[parsed].first>
            - else:
                - define page-index 1
            - if ( not <list[next|prev|previous].contains[<[page]>]> ):
                # |------- invalid page -------| #
                - define message "<[log_prefix]> - open() -<&gt> arg '<[page]>' for parameter 'page' is invalid."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
                - define page:!
        # |------- parse gui-id -------| #
        - if ( not <[page].exists> ):
            - if ( <[current]> == null ) && ( <[gui-id]||null> == null || not <[gui-id].exists> ):
                # |------- none -------| #
                - goto skip-open
            - else if ( <[current]> != null ) && ( <[gui-id]||null> == null || not <[gui-id].exists> ):
                # |------- default -------| #
                - define gui-id <[current]>
            - define parsable <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]>>
            - define parsed <[parsable].split[_]||<list>>
            - if ( <[parsable].contains_text[<[identifier]>]> ):
                - define gui-id <[parsable].after[<[identifier]>]||<[parsable]>>
            - else:
                - define gui-id <[parsable]>
            - if ( <[previous-cache]> contains <[gui-id]> ):
                # |------- page-id -------| #
                - define parsable previous_<[previous-cache].get[<[previous-cache].find[<[gui-id]>]>].to[<[previous-cache].find[<[previous-cache].last>]>].size>
                - define parsed <[parsable].split[_]||<list>>
                - if ( <[parsed].last.is_integer> ):
                    - define page-index <[parsed].last>
                - else:
                    - define page-index 1
                - define page <[parsed].first||<[parsed].last>>
        #- if ( <[page].exists> ):
            #- narrate "page: <[page]||null><&nl>index: <[page-index]||null>"
        #- else:
            #- narrate "gui-id: <[gui-id]||null>"
        # |------- validate target -------| #
        - choose <[page]||null>:
            - case next:
                # |------- parse next-cache -------| #
                - if ( <[page-index]> > 1 ):
                    - define page-index <[page-index].sub[1]>
                    - define iterate true
                - if ( <[next-cache]> contains <[current]> ):
                    - define cached <[next-cache].exclude[<[current]>].get[1].to[<[page-index]>]||<list>>
                - else:
                    - define cached <[next-cache].get[1].to[<[page-index]>]||<list>>
                - define target <[cached].last||null>
            - case previous prev:
                # |------- parse previous-cache -------| #
                - define removed <[previous-cache].reverse.get[1].to[<[page-index]>].reverse||<list>>
                - define cached <[previous-cache].reverse.remove[1].to[<[page-index]>].reverse||<list>>
                - define target <[removed].first||null>
            - default:
                # |------- default target -------| #
                - define target <[gui-id]>

        # |------- validate inventory -------| #
        #- narrate "target: <[target]>"
        - if ( <[target]> != null ) && ( <[validate]||true> ):
            - ~run gui_manager_validate def.gui-id:<[target]> def.index:<[index]||null> def.title:<[title]||null> def.contents:<[contents]||null> def.fill:<[fill]||null> def.auto-title:<[auto-title]||true> save:validated
        - define inventory <entry[validated].created_queue.determination.get[1]||null>
        - if ( <[inventory]> != null ) && ( <[ignore]||false> ) && ( not <[blacklist].contains[<[target]>]> ):
            - flag <player> gui_manager.apps.<[app-id]>.blacklist:->:<[target]>
            - define blacklist:->:<[target]>
        # |------- validate cache -------| #
        - choose <[page]||null>:
            - case next:
                - if ( <[inventory]> != null ) && ( not <[blacklist].contains[<[target]>]> ):
                    - if ( not <[previous-cache].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                        - flag <player> gui_manager.previous:->:<[current]>
                        - define previous-cache:->:<[current]>
                    - if ( <[iterate]||false> ):
                        - foreach <[cached]> as:id:
                            - if ( not <[previous-cache].contains[<[id]>]> ) && ( not <[blacklist].contains[<[id]>]> ):
                                - flag <player> gui_manager.previous:->:<[id]>
                                - define previous-cache:->:<[id]>
                            - else:
                                - define message "<[log_prefix]> - next() -<&gt> '<[id]>' already found in previous cache."
                                - debug log <[message]>
                                - log <[message]> type:warning file:<[log_path]>
            - case previous prev:
                - if ( <[inventory]> != null ) && ( not <[blacklist].contains[<[target]>]> ) && ( <[current]> != <[root]> ) && ( <[cached].any.exists> ):
                    - flag <player> gui_manager.previous:!|:<[cached]>
                    - define previous-cache:!|:<[cached]>
                    - if ( not <[next-cache].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                        - flag <player> gui_manager.next:->:<[current]>
                        - define next-cache:->:<[current]>
                - else if ( <[target]> == null ) && ( <[cached].is_empty> ):
                    # |------- close gui -------| #
                    - inventory close
                    - playsound <player> sound:<script[gui_manager].data_key[data.config.sounds].get[left-click-button]> pitch:1
                    - flag <player> gui_manager.current:null
                    - flag <player> gui_manager.next:<list[<empty>]>
                    - define current null
                    - define next-cache <list>
                    - define message "<[log_prefix]> - prev() -<&gt> '<[app-id]>' closed."
                    - define message_1 "<[log_prefix]> - build() -<&gt> <player.flag[gui_manager.apps.<[app-id]>.ast].to_json>"
                    - if ( <player.flag[gui_manager.debug]> ):
                        - debug log <[message]>
                        - narrate "<&nl>current: <[current]><&nl>next: <[next-cache]><&nl>previous: <[previous-cache]><&nl>"
                        - log <[message]> type:info file:<[log_path]>
                        - log <[message_1]> type:info file:<[log_path]>
                    - determine false
            - default:
                - if ( <[inventory]> != null ) && ( not <[blacklist].contains[<[target]>]> ):
                    - if ( <[current]> == <[root]> ) && ( <[target]> != <[next-cache].get[1]||null> ):
                        - flag <player> gui_manager.next:!|:<list>
                        - define next-cache:!|:<list>
                    - if ( <[current]> != null ) && ( <[current]> != <[root]> ):
                        - if ( not <[next-cache].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ):
                            - flag <player> gui_manager.next:->:<[current]>
                            - define next-cache:->:<[current]>
                    - if ( <[target]> != null ) && ( <[target]> != <[root]> ) && ( <[current]> != null ) && ( <[current]> != <[target]> ):
                        - if ( not <[previous-cache].contains[<[current]>]> ) && ( not <[blacklist].contains[<[current]>]> ) :
                            - flag <player> gui_manager.previous:->:<[current]>
                            - define previous-cache:->:<[current]>
                        - if ( <[built].any> ) && ( not <[next-cache].contains[<[target]>]> ):
                            - if ( <[next-cache].any> ):
                                - ~run gui_manager_get_parent def.gui-id:<[next-cache].last> save:check-relative
                                - if ( <entry[check-relative].created_queue.determination.get[1]||<[current]>> == <[previous-cache].last||null> ):
                                    - flag <player> gui_manager.next:<-:<[next-cache].last>
                                    - define next-cache:<-:<[next-cache].last>
                            - flag <player> gui_manager.next:->:<[target]>
                            - define next-cache:->:<[target]>

        - mark skip-open
        # |------- validate multi -------| #
        - if ( <[gui-id].any.exists||false> ):
            - if ( <[gui-id].keys.exists> ):
                # |------- map -------| #
                - narrate test
            - else:
                # |------- list -------| #
                - define filtered <[gui-id].parse_tag[<[parse_value].replace_text[regex:<&sp>|-].with[_]>].filter_tag[<script[<[identifier]><[filter_value]>].container_type.equals[inventory]>]||<list>>
                - define target <[filtered].last||<[filtered].get[<[filtered].size>]>>
                - ~run gui_manager_validate def.gui-id:<[target]> def.index:<[index]||null> def.title:<[title]||null> def.contents:<[contents]||null> def.fill:<[fill]||null> def.auto-title:<[auto-title]||true> save:validated
                - define inventory <entry[validated].created_queue.determination.get[1]||null>
                - if ( <[inventory]||null> != null ):
                    - ~run gui_manager_build def.gui-id:<[filtered]> save:build-multi
                    - if ( <entry[build-multi].created_queue.determination.get[1]||false> ):
                        - define next-cache <[filtered].exclude[<[filtered].first||<[filtered].get[1]>>]>
                        - define previous-cache <[filtered].exclude[<[filtered].last||<[filtered].get[<[filtered].size>]>>]>
                        - flag <player> gui_manager.next:<[next-cache]>
                        - flag <player> gui_manager.previous:<[previous-cache]>
                        - define built:|:<[filtered]>
        # |------- open inventory -------| #
        - if ( <[inventory]||null> != null ):
            - if ( <[cache-reset]||false> ):
                # |------- reset next-cache -------| #
                - define current-index <[next-cache].find[<[target]>]>
                - define last-index <[next-cache].find[<[next-cache].last||<[current-index]>>]>
                - if ( <[next-cache].size> > 1 ) && ( <[last-index]> > <[current-index]> ):
                    - define next-cache <[next-cache].remove[<[current-index].add[1]>].to[<[last-index]>]||null>
                    - flag player gui_manager.next:<[next-cache]>
            # |------- set current -------| #
            - if ( not <[blacklist].contains[<[target]>]> ):
                - if ( not <[built].contains[<[target]>]> ):
                    - ~run gui_manager_build def.gui-id:<[target]>
                - flag <player> gui_manager.current:<[target]>
                - define current <[target]>
            # |------- open target -------| #
            - playsound <player> sound:<script[gui_manager].data_key[data.config.sounds].get[left-click-button]> pitch:1
            - inventory open destination:<[inventory]>
            - define cached-index <player.flag[gui_manager.apps.<[app-id]>.inventories.<[target]>.index]||null>
            - if ( <[cached-index]> == null ):
                - define message "<[log_prefix]> - <[page].substring[1,4]||open>() -<&gt> '<[target]>' opened."
            - else:
                - define message "<[log_prefix]> - <[page].substring[1,4]||open>() -<&gt> '<[target]>_<[cached-index]>' opened."
            - if ( <player.flag[gui_manager.debug]> ):
                - debug log <[message]>
                - narrate "<&nl>current: <[current]><&nl>next: <[next-cache]><&nl>previous: <[previous-cache]><&nl>"
                - log <[message]> type:info file:<[log_path]>
            # |------- return -------| #
            - determine true
        - else if ( <[target]||null> != null ):
            # |------- missing inventory -------| #
            - define message "<[log_prefix]> - open() -<&gt> failed to open '<[target]>' gui."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[gui-id]||null> != null ):
            # |------- missing inventory -------| #
            - define message "<[log_prefix]> - open() -<&gt> failed to open '<[gui-id]>' gui."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[gui-id]||null> == null ):
            # |------- missing gui-id -------| #
            - define message "<[log_prefix]> - open() -<&gt> must open a valid 'gui-id' before using default args."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else:
            # |------- missing initialization -------| #
            - define message "<[log_prefix]> - open() -<&gt> must be instantiated before using 'gui_manager.open'."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false



gui_manager_validate:
    #####################################################################
    # | ---  |                validate gui task                |  --- | #
    #####################################################################
    # | ---                                                       --- | #
    # | ---  Required:  gui-id                                    --- | #
    # | ---                                                       --- | #
    # | ---  Optional:  app-id | index | title | contents | fill  --- | #
    # | ---             auto-title                                --- | #
    # | ---                                                       --- | #
    #####################################################################
    # | ---                                                       --- | #
    # | ---  Returns:  inventory tag | bool                       --- | #
    # | ---                                                       --- | #
    #####################################################################
    # | ---                                                       --- | #
    # | ---  Run: true | Await: true | Inject: false              --- | #
    # | ---                                                       --- | #
    #####################################################################
    type: task
    debug: false
    definitions: app-id | gui-id | index | title | contents | fill | auto-title
    script:
        - waituntil <util.queues.exclude[<queue>].filter_tag[<[filter_value].script.name.equals[<script.name>].and[<[filter_value].player.equals[<player>]>].and[<[filter_value].state.equals[running]>]>].is_empty> max:10t rate:1t
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine null
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - if ( <[gui-id]||null> == null ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "<[log_prefix]> - validate() -<&gt> parameter 'gui-id' is missing."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine null
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        - define inventories gui_manager.apps.<[app-id]>.inventories
        - define identifier <script[gui_manager].parsed_key[data.config.ids.valid-gui]>
        - define properties <player.flag[<[inventories]>].get[<[gui-id]>]||<map>>
        # |------- instantiate inventory -------| #
        - define inventory <inventory[<[identifier]><[gui-id]>]||null>
        - if ( <[inventory]> == null ):
            # |------- missing script -------| #
            - define message "<[log_prefix]> - validate() -<&gt> failed to instantiate '<[gui-id]>' inventory."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine null
        - if ( <[contents].id_type.exists||false> ):
            - define copied <[contents].list_contents||<list>>
            - adjust <[inventory]> contents:<[copied]>
            - define contents:!
        - else:
            - if ( <[inventory].list_contents.is_empty> ) && ( <[contents]> != null || <[fill]> != null ):
                - adjust <[inventory]> contents:<list.pad_right[<[inventory].size>].replace[<empty>].with[<item[structure_void]>]>
        # |------- cache properties -------| #
        - if ( not <player.flag[<[inventories]>].if_null[<map>].keys.contains[<[gui-id]>]> ):
            - flag <player> <[inventories]>.<[gui-id]>:<map>
        # |------- validate properties -------| #
        - if ( <[contents]||null> != null ) || ( <[fill]||null> != null ):
            # |------- adjust contents -------| #
            - define slots <[inventory].list_contents.find_all_matches[air]||<list>>
            - if ( <[inventory].size> == <[inventory].list_contents.find_all_matches[structure_void].if_null[<list>].size> ):
                - define slots <util.list_numbers[to=<[inventory].size>]>
            - if ( <[slots].is_empty> ):
                # |------- null slots -------| #
                - define message "<[log_prefix]> - validate() -<&gt> inventory '<[identifier]><[gui-id]>' does not contain any empty slots."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - else:
                # |------- parameter check -------| #
                - if ( <[contents]||null> == null ):
                    - define contents <list>
                - if ( not <[contents].any.exists> ):
                    # |------- invalid parameter 'list' -------| #
                    - define message "<[log_prefix]> - validate() -<&gt> parameter 'list' must be of object type list."
                    - debug log <[message]>
                    - log <[message]> type:severe file:<[log_path]>
                    - define contents <list>
                # |------- parse list -------| #
                - define parsed <[contents].parse_tag[<[parse_value].material.exists>].find_all[false]||<list>>
                - if ( <[parsed].any> ):
                    - define invalid <[contents].get[<[parsed].first>].to[<[parsed].last>]||<list>>
                - else:
                    - define invalid <list>
                - define contents <[contents].exclude[<[invalid]||<list>>]||<[contents]>>
                - if ( <[invalid].any> ):
                    # |------- invalid found -------| #
                    - define message "<[log_prefix]> - validate() -<&gt> removed '<[invalid].size>' items from '<[gui-id]>' contents list. Parameter 'list' must be a list of item objects."
                    - debug log <[message]>
                    - log <[message]> type:warning file:<[log_path]>
                # |------- build pages -------| #
                - define pages <[contents].sub_lists[<[slots].size>]||<list>>
                - define last <[pages].last||<[pages]>>
                - if ( <[pages].is_empty||true> ):
                    - define pages:->:<list>
                # |------- validate empty -------| #
                - if ( <[last].size> < <[slots].size> ):
                    - if ( <[fill]||null> == null ):
                        - define fill <item[air]>
                    - else if ( not <[fill].material.exists> ):
                        # |------- invalid parameter 'fill' -------| #
                        - define message "<[log_prefix]> - validate() -<&gt> parameter 'fill' must be of object type item."
                        - debug log <[message]>
                        - log <[message]> type:warning file:<[log_path]>
                        - if ( <[contents].is_empty> ):
                            - define fill null
                        - else:
                            - define fill <item[air]>
                    # |------- fill empty -------| #
                    - define pages:<-:<[last]>
                    - define last <[last].pad_right[<[slots].size>].replace[<empty>].with[<[fill]>]>
                    - define pages:->:<[last]>
                # |------- final check -------| #
                - if ( <[pages].size> == 1 ) && ( not <[last].any> ):
                    - if ( <[properties].get[pages]||null> != null ):
                        - flag <player> <[inventories]>.<[gui-id]>.index:!
                        - flag <player> <[inventories]>.<[gui-id]>.pages:!
                    - goto skip-caching
                # |------- cache pages -------| #
                - foreach <[pages]> as:content-list:
                    - define cached_contents <[inventory].list_contents>
                    - foreach <[slots].map_with[<[content-list]>]> key:slot as:item:
                        - define cached_contents <[cached_contents].set[<[item]>].at[<[slot]>]>
                    - flag <player> <[inventories]>.<[gui-id]>.pages.<[loop_index]>:<[cached_contents]>
                # |------- update flags -------| #
                - flag <player> <[inventories]>.<[gui-id]>.pages:<map.include[<player.flag[<[inventories]>.<[gui-id]>.pages].get_subset[<util.list_numbers[to=<[pages].size>]>]>]>
                - define cached-index <player.flag[<[inventories]>.<[gui-id]>.index]||null>
                - if ( <[cached-index]> == null ):
                    - flag <player> <[inventories]>.<[gui-id]>.index:1
                - else if ( <[cached-index]||1> > <[pages].size> ):
                    - flag <player> <[inventories]>.<[gui-id]>.index:<[cached-index].sub[<[cached-index].mod[<[pages].size>]>]>
        # |------- check cached properties -------| #
        - mark skip-caching
        - define original <inventory[<[identifier]><[gui-id]>].title>
        - define properties <player.flag[<[inventories]>].get[<[gui-id]>]||null>
        - if ( <[properties].get[pages]||null> != null ):
            # |------- page data -------| #
            - define page <[index]||null>
            - define index <[properties].get[index]||1>
            - define pages <[properties].get[pages]||<map>>
            # |------- adjust index -------| #
            - choose <[page]||null>:
                - case first start:
                    - define index 1
                - case last end:
                    - define index <[pages].size>
                - case next:
                    - if ( <[index].add[1]> > <[pages].size> ):
                        - define index <[pages].size>
                    - else:
                        - define index:++
                - case previous prev:
                    - if ( <[index].sub[1]> >= 1 ):
                        - define index:--
                - default:
                    - if ( <[page]> != null ) && ( not <[page].is_integer> ):
                        - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[gui-id]>' does not recognize index keyword '<[page]>'."
                        - debug log <[message]>
                        - log <[message]> type:warning file:<[log_path]>
                    - else if ( <[page].is_integer> ):
                        - if ( <[page]> >= 1 ):
                            - if ( <[page]> > <[pages].size> ):
                                # |------- max index -------| #
                                - define index <[pages].size>
                                - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[gui-id]>' does not contain index '<[page]>'. Defaulting to '<[pages].size>'."
                                - debug log <[message]>
                                - log <[message]> type:warning file:<[log_path]>
                            - else:
                                - define index <[page]>
                        - else:
                            # |------- min index -------| #
                            - define index 1
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[gui-id]>' does not contain index '<[page]>'. Defaulting to '1'."
                            - debug log <[message]>
                            - log <[message]> type:warning file:<[log_path]>
            # |------- adjust contents -------| #
            - define content <[pages].get[<[index]>]||<list>>
            - if ( <[content].is_empty> ):
                # |------- invalid content -------| #
                - define message "<[log_prefix]> - validate() -<&gt> index '<[index]>' could not be found."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - else:
                - adjust <[inventory]> contents:<[content]>
                - flag <player> <[inventories]>.<[gui-id]>.index:<[index]>
        # |------- adjust title -------| #
        - if ( <[title]||null> != null ):
            - flag <player> <[inventories]>.<[gui-id]>.title:<[title]||null>
        - else if ( <[properties].get[title]||null> != null ):
            - define title <[properties].get[title]||null>
        - else:
            - define title <[original]>
        - if ( <[auto-title]||true> ) && ( <[index]||null> != null ) && ( <[pages].size||1> > 1 ) && ( <[index].is_integer> ):
            - adjust <[inventory]> title:<[title]><&sp>-<&sp><[index]>
        - else if ( <[inventory].title> != <[title]> ):
            - adjust <[inventory]> title:<[title]>
        # |------- return inventory -------| #
        - determine <[inventory]>



gui_manager_build:
    ##########################################################
    # | ---  |              build task              |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  gui-id(s)                      --- | #
    # | ---                                            --- | #
    # | ---  Optional:  app-id | parent-id             --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Returns:  bool                            --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Run: true | Await: true | Inject: false   --- | #
    # | ---                                            --- | #
    ##########################################################
    type: task
    debug: false
    definitions: app-id | gui-id | gui-ids | parent-id
    script:
        - waituntil <util.queues.exclude[<queue>].filter_tag[<[filter_value].script.name.equals[<script.name>].and[<[filter_value].player.equals[<player>]>]>].is_empty> max:10t rate:1t
        # |------- parameter check -------| #
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        # |------- check multi -------| #
        - if ( <[gui-id].any.exists||false> ):
            - define parsed <[gui-id].parse_tag[<[parse_value].replace_text[regex:<&sp>|-].with[_]||<[parse_value]>>]||<list>>
            - flag <player> gui_manager.apps.<[app-id]>.ast.<[parsed].separated_by[.]>:<empty>
            - flag <player> gui_manager.apps.<[app-id]>.built:|:<[parsed]>
            - define message "<[log_prefix]> - build() -<&gt> built '<[parsed].separated_by[.]>' to ast."
            - if ( <player.flag[gui_manager.debug]> ):
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>
            - determine true
        # |------- ast data -------| #
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - define parent-id <[parent-id].replace_text[regex:<&sp>|-].with[_]||<[parent-id]||null>>
        - if ( <[parent-id]> == null ):
            - define parent-id <player.flag[gui_manager.previous].last||<player.flag[gui_manager.current]||null>>
            - if ( <[parent-id]> == null ):
                - flag <player> gui_manager.apps.<[app-id]>.ast.<[gui-id]>:<empty>
                - goto built
        - define filtered <[ast].deep_keys.filter_tag[<[filter_value].split[.].contains[<[parent-id]>]>].include[<[ast].keys.filter_tag[<[filter_value].equals[<[parent-id]>]>]>]>
        - define parsed <[filtered].parse_tag[<[parse_value].split[.].get[1].to[<[parse_value].split[.].find[<[parent-id]>]>]>].deduplicate>
        - if ( <[parsed].size> > 1 ):
            # |------- maximum -------| #
            - define message "<[log_prefix]> - build() -<&gt> gui '<[gui-id]>' found too many parent nodes and is limited to one (1)."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[parsed].is_empty> ):
            - flag <player> gui_manager.apps.<[app-id]>.ast.<[gui-id]>:<empty>
            - goto built
        - define branch <[parsed].get[1].separated_by[.]>
        - flag <player> gui_manager.apps.<[app-id]>.ast.<[branch]>.<[gui-id]>:<empty>
        - mark built
        # |------- success -------| #
        - flag <player> gui_manager.apps.<[app-id]>.built:->:<[gui-id]>
        - define message "<[log_prefix]> - build() -<&gt> built '<[gui-id]>' to ast."
        - if ( <player.flag[gui_manager.debug]> ):
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>
        - determine true



gui_manager_purge_logs:
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
    type: task
    debug: false
    definitions: app-id
    script:
        # |------- define data -------| #
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        - if ( <[app-id]> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - stop
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        # |------- parse -------| #
        - define message "<[log_prefix]> - purge() -<&gt> purge triggered. Gathering logs..."
        - if ( <player.flag[gui_manager.debug]> ):
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>
        - define dir <script[gui_manager].parsed_key[data.config.log.dir].if_null[plugins/Denizen/data/logs/gui_manager/].split[/].separated_by[/]>
        - define path <[dir].after[denizen/]>/<[app-id]>
        - define latest <util.time_now.format[MM-dd-yyyy]>
        - if ( <util.has_file[<[path]>/<[latest]>.txt]> ):
            - define logs <util.list_files[<[path]>].if_null[<list[<empty>]>]>
            - define max <script[gui_manager].data_key[data.config.log.max].if_null[6]>
            - define amount <[logs].exclude[<[latest]>.txt].size>
            - if ( not <[max].is_integer> ):
                # |------- invalid int -------| #
                - define message "<[log_prefix]> - purge() -<&gt> parameter max '<[max]>' is not of type integer."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - else if ( <[logs].size> >= <[max]> ):
                # |------- purge -------| #
                - foreach <[logs].exclude[<[latest]>.txt].if_null[<[logs]>]> as:log:
                    - adjust server delete_file:<[path]>/<[log]>
                - if ( <[amount]> > 1 ):
                    - define message "<[log_prefix]> - purge() -<&gt> '<[amount]>' logs purged."
                - else:
                    - define message "<[log_prefix]> - purge() -<&gt> '<[amount]>' log purged."
                - if ( <player.flag[gui_manager.debug]> ):
                    - debug log <[message]>
                    - log <[message]> type:info file:<[log_path]>
            - else if ( <player.flag[gui_manager.debug]> ):
                # |------- cancel -------| #
                - if ( <[amount]> > 1 ):
                    - define message "<[log_prefix]> - purge() -<&gt> purge cancelled. '<[logs].size>' logs found."
                - else:
                    - define message "<[log_prefix]> - purge() -<&gt> purge cancelled. '<[logs].size>' log found."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>



# | ----------------------------------------------  GUI MANAGER | RESET TASKS  ---------------------------------------------- | #



gui_manager_reset_ast:
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
    type: task
    debug: false
    definitions: app-id
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
        - else:
            # |------~ data -------| #
            - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
            - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
            - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
            # |------- reset ast -------| #
            - define cached <player.flag[gui_manager.apps.<[app-id]>.ast]||null>
            - ~run gui_manager path:build save:build
            - if ( not <entry[build].created_queue.determination.get[1]||false> ):
                # |------- failed -------| #
                - if ( <[cached]> != null ):
                    - flag <player> gui_manager.apps.<[app-id]>.ast:<[cached]>
                - define message "<[log_prefix]> - reset.ast() -<&gt> '<[app-id]>' ast reset failed."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - else if ( <player.flag[gui_manager.debug]> ):
                # |------- success -------| #
                - define message "<[log_prefix]> - reset.ast() -<&gt> abstract syntax tree reset."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>



gui_manager_reset_cache:
    #########################################################
    # | ---  |             reset cache             |  --- | #
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
    type: task
    debug: false
    definitions: app-id
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
        - else:
            # |------~ data -------| #
            - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
            - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
            - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
            # |------- reset cache -------| #
            - flag <player> gui_manager.current:!
            - flag <player> gui_manager.next:<list>
            - flag <player> gui_manager.previous:<list>
            - flag <player> gui_manager.apps.<[app-id]>.ast:<map>
            - flag <player> gui_manager.apps.<[app-id]>.built:<list>
            - flag <player> gui_manager.apps.<[app-id]>.inventories:<map>
            - flag <player> gui_manager.apps.<[app-id]>.blacklist:<list>
            - define message "<[log_prefix]> - reset.cache() -<&gt> cache flags reset"
            - if ( <player.flag[gui_manager.debug]> ):
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>



# | ----------------------------------------------  GUI MANAGER | GET TASKS  ---------------------------------------------- | #



gui_manager_get_version:
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
    type: task
    debug: false
    definitions: app-id
    script:
        - define version <script[gui_manager].data_key[data.version].if_null[null]>
        - if ( <[version]> != null ):
            - determine <[version]>
        - else:
            - narrate "version could not be located."
            - determine false



gui_manager_get_opened:
    ##########################################################
    # | ---  |              get opened              |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  none                           --- | #
    # | ---                                            --- | #
    # | ---  Optional:  app-id | gui-id                --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Returns:  list | bool                     --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Run: true | Await: true | Inject: false   --- | #
    # | ---                                            --- | #
    ##########################################################
    type: task
    debug: false
    definitions: app-id | gui-id
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------- gui data -------| #
        - define opened <player.flag[gui_manager.apps.<[app-id]>.inventories].keys||<list>>
        - if ( <[gui-id]||null> != null ):
            - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]>>
            # |------- return bool -------| #
            - if ( <[opened]> contains <[gui-id]> ):
                - determine true
            - else:
                - determine false
        # |------- return all -------| #
        - determine <[opened]>



gui_manager_get_properties:
    ##########################################################
    # | ---  |            get properties            |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  gui-id                         --- | #
    # | ---                                            --- | #
    # | ---  Optional:  app-id                         --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Returns:  map | bool                      --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Run: true | Await: true | Inject: false   --- | #
    # | ---                                            --- | #
    ##########################################################
    type: task
    debug: false
    definitions: app-id | gui-id
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - if ( <[gui-id]||null> == null ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "<[log_prefix]> - get.cache() -<&gt> parameter 'gui-id' is missing."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - define properties <player.flag[gui_manager.apps.<[app-id]>.inventories].get[<[gui-id]>]||null>
        - if ( <[properties]> == null ):
            # |------- missing -------| #
            - define message "<[log_prefix]> - get.cache() -<&gt> gui-id '<[gui-id]>' properties have not been cached."
            - debug log <[message]>
            - log <[message]> type:warning file:<[log_path]>
            - determine false
        # |------- return -------| #
        - determine <[properties]>



gui_manager_get_ast:
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
    type: task
    debug: false
    definitions: app-id
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - if ( <[ast]> == null ):
            # |------- missing ast -------| #
            - define message "<[log_prefix]> - get.ast() -<&gt> could not locate 'ast'. App must be initialized before use."
            - debug log <[message]>
            - log <[message]> type:warning file:<[log_path]>
            - determine false
        # |------- return ast -------| #
        - determine <[ast]>



gui_manager_get_root:
    ############################################################
    # | ---  |                get root                |  --- | #
    ############################################################
    # | ---                                              --- | #
    # | ---  Required:  none                             --- | #
    # | ---                                              --- | #
    # | ---  Optional:  app-id | gui-id | ignore         --- | #
    # | ---                                              --- | #
    ############################################################
    # | ---                                              --- | #
    # | ---  Returns:  str | bool                        --- | #
    # | ---                                              --- | #
    ############################################################
    # | ---                                              --- | #
    # | ---  Run: true | Await: true | Inject: false     --- | #
    # | ---                                              --- | #
    ############################################################
    type: task
    debug: false
    definitions: app-id | gui-id | ignore
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        # |------- get data -------| #
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        - define inventories <player.flag[gui_manager.apps.<[app-id]>.inventories]||<map>>
        # |------- check data -------| #
        - if ( <[gui-id]> == null ) || ( not <[built].contains[<[gui-id]>]> ):
            - define gui-id <player.flag[gui_manager.current]||null>
        - if ( <[ignore]||false> ) || ( <[built].is_empty> ):
            # |------- ignore -------| #
            - determine <[gui-id]||null>
        - define filtered <[ast].deep_keys.filter_tag[<[filter_value].split[.].contains[<[gui-id]>]>].include[<[ast].keys.filter_tag[<[filter_value].equals[<[gui-id]>]>]>]>
        - define parsed <[filtered].parse_tag[<[parse_value].split[.].first||<[parse_value].split[.].last>>].deduplicate>
        - if ( <[parsed].size> > 1 ):
            # |------- maximum -------| #
            - define message "<[log_prefix]> - get.root() -<&gt> gui '<[gui-id]>' found too many root nodes and is limited to one (1)."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[parsed].is_empty> ):
            # |------- default -------| #
            - define root <[ast].sort_by_value[size].keys.first||<[gui-id]>>
            - define message "<[log_prefix]> - get.root() -<&gt> gui '<[gui-id]>' could not locate root. Defaulting to '<[root]>'."
            - debug log <[message]>
            - log <[message]> type:warning file:<[log_path]>
            - determine <[root]>
        # |------- success -------| #
        - determine <[parsed].get[1]>



gui_manager_get_parent:
    ########################################################
    # | ---  |             get parent             |  --- | #
    ########################################################
    # | ---                                          --- | #
    # | ---  Required:  gui-id                       --- | #
    # | ---                                          --- | #
    # | ---  Optional:  app-id | ignore              --- | #
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
    type: task
    debug: false
    definitions: app-id | gui-id | ignore
    script:
        # |------- task data -------| #
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine null
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - if ( <[gui-id]||null> == null ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "<[log_prefix]> - get.parent() -<&gt> gui '<[gui-id]>' parameter 'gui-id' is missing."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
            - determine null
        # |------- gui data -------| #
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        - define inventories <player.flag[gui_manager.apps.<[app-id]>.inventories]||<map>>
        - if ( <[ignore]||false> ):
            # |------- ignore -------| #
            - determine null
        # |------- ast data -------| #
        - define current <player.flag[gui_manager.current]||null>
        - if ( <[current]> == null ) || ( <[current]> == <[gui-id]> ):
            - determine null
        - else if ( <[current]> != null ):
            - define filtered <[ast].deep_keys.parse_tag[<[parse_value].split[.]>].filter_tag[<[filter_value].contains[<[gui-id]>]>]||<list>>
            - if ( <[filtered].is_empty> ):
                # |------- missing -------| #
                - define message "<[log_prefix]> - get.parent() -<&gt> could not locate '<[gui-id]>' in ast."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
                - determine null
            - define branch <[filtered].get[1]||<list>>
            - if ( <[branch].any> ):
                - define parsed <[branch].get[<[branch].find[<[gui-id]>].sub[1]||1>]||null>
                - if ( <[parsed]> != null ) || ( <[parsed]> != <[gui-id]> ):
                    - determine <[parsed]>
            - determine null



gui_manager_get_siblings:
    ########################################################
    # | ---  |            get siblings            |  --- | #
    ########################################################
    # | ---                                          --- | #
    # | ---  Required:  gui-id                       --- | #
    # | ---                                          --- | #
    # | ---  Optional:  app-id | ignore              --- | #
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
    type: task
    debug: false
    definitions: app-id | gui-id | ignore
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine null
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - if ( <[gui-id]||null> == null ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "parameter 'gui-id' is missing."
            - ~run gui_manager path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
            - determine null
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - ~run gui_manager path:get.parent def.gui-id:<[gui-id]> save:parent
        - define parent <entry[parent].created_queue.determination.get[1]||null>
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        - define inventories <player.flag[gui_manager.apps.<[app-id]>.inventories]||<map>>
        - if ( <[ignore]||false> ):
            # |------- ignore -------| #
            - determine null
        # |------- parse ast -------| #
        - if ( <[parent]> == null || <[parent]> == <empty> ) && ( <[ast].keys> contains <[gui-id]> ):
            # |------- return root nodes -------| #
            - determine <[ast].keys>
        - else if ( <[parent]> != null ):
            - foreach <[ast].deep_keys> as:branch:
                - if ( <[parent]> == <[branch]> ):
                    # |------- return siblings -------| #
                    - define siblings <[ast].get[<[branch]>].keys||<list>>
                    - determine <[siblings].keys.exclude[<[gui-id]>]||<list>>
                - else if ( <[branch].split[.]||<list>> contains <[gui-id]> ):
                    - foreach <[branch].split[.]> as:leaf:
                        - if ( <[parent]> == <[leaf]> ):
                            # |------- return siblings -------| #
                            - define siblings <[ast].deep_get[<[branch].before[.<[parent]>]>.<[parent]>]||<list>>
                            - determine <[siblings].keys.exclude[<[gui-id]>]||<list>>
        # |------- missing siblings -------| #
        - define message "could not locate 'siblings' for '<[gui-id]>'."
        - ~run gui_manager path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
        - determine null



gui_manager_get_lineage:
    #########################################################
    # | ---  |             get lineage             |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  gui-id                        --- | #
    # | ---                                           --- | #
    # | ---  Optional:  app-id | ignore               --- | #
    # | ---                                           --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Returns:  list | bool                    --- | #
    # | ---                                           --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Run: true | Await: true | Inject: false  --- | #
    # | ---                                           --- | #
    #########################################################
    type: task
    debug: false
    definitions: app-id | gui-id | ignore
    script:
        - if ( not <[app-id].exists> ):
            - define app-id <player.flag[gui_manager.opened]||null>
        # |------- parameter check -------| #
        - if ( <[app-id]||null> == null ):
            # |------- missing parameter 'app-id' -------| #
            - debug error "parameter 'app-id' is missing. App must be initialized before use."
            - determine false
        # |------~ data -------| #
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/]||<script[gui_manager].parsed_key[data.config.log.dir]>>
        - define log_path <[log_dir]>/<[app-id]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<[app-id].replace[_].with[<&sp>]||<[app-id]>>] <player.name>"
        - if ( <[gui-id]||null> == null ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "parameter 'gui-id' is missing."
            - ~run gui_manager path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
            - determine false
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_]||<[gui-id]||null>>
        - ~run gui_manager path:get.parent def.gui-id:<[gui-id]> save:parent
        - define parent <entry[parent].created_queue.determination.get[1]||null>
        - define ast <player.flag[gui_manager.apps.<[app-id]>.ast]||<map>>
        - define built <player.flag[gui_manager.apps.<[app-id]>.built]||<list>>
        - define inventories <player.flag[gui_manager.apps.<[app-id]>.inventories]||<map>>
        - if ( <[ignore]||false> ) || ( not <[built].contains[<[gui-id]>]> && not <[inventories].is_empty> ):
            # |------- ignore -------| #
            - determine null
        - if ( <[ast]> == null ):
            # |------- missing ast -------| #
            - define message "could not locate 'ast'. App must be initialized before use."
            - ~run gui_manager path:logger.log def.level:error def.task:get.siblings def.message:<[message]>
            - determine false
        # |------- check parent -------| #
        - if ( <[parent]> == null || <[parent]> == <empty> ) && ( <[ast].keys> contains <[gui-id]> ):
            # |------- return empty -------| #
            - determine <list>
        # |------- parse lineage -------| #
        - define lineages <[ast].deep_keys.filter_tag[<[filter_value].contains_text[<[gui-id]>]>]>
        - define parsed <[lineages].parse_tag[<[parse_value].split[.].get[1].to[<[parse_value].split[.].find[<[gui-id]>].sub[1]||1>].separated_by[.]>].deduplicate||<list>>
        - if ( <[parsed].is_empty> ):
            # |------- maximum -------| #
            - define message "could not locate 'lineage' for '<[gui-id]>'."
            - ~run gui_manager path:logger.log def.level:error def.task:get.lineage def.message:<[message]>
            - determine false
        - else if ( <[parsed].size> > 1 ):
            # |------- maximum -------| #
            - define message "gui '<[gui-id]>' found in multiple lineages and is limited to one (1)."
            - ~run gui_manager path:logger.log def.level:error def.task:get.lineage def.message:<[message]>
            - determine false
        - determine <[parsed].get[1].split[.]||<list>>



# | ------------------------------------------------------------------------------------------------------------------------------ | #


