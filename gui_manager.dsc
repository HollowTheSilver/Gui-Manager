# + ----------------------------------------------------------------------------------------------------------------------------------- +
# |
# |
# |  Gui Manager - Denizen Library
# |
# |
# + ---------------------------------------------------------------------------------------------------------------------------------- +
#
#
# @Htools               LLC
# @author               HollowTheSilver
# @date                 10/24/2023
# @script-version       DEV-2.0.1
# @denizen-build-1.2.8  REL-1794
#
#
# ------------------------------------------------------------------------------------------------------------------------------------ +
#
#
# Description:
#   - A denizen library designed to simplify and expand the front end design pattern for gui type inventory scripts, and contains various
#   - task and event scripts capable of tracking, updating and caching inventory data throughout runtime.
#
#   - This library is intended to manage instanced hierarchical user interfaces concurrently, and maintain any related or paginated data.
#
#
# ------------------------------------------------------------------------------------------------------------------------------------ +
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

        on player flagged:gui_manager.session.id clicks in inventory:
            - determine cancelled passively

        on player flagged:gui_manager.session.id closes inventory:
            # |------- session check -------| #
            - define destroy <player.flag[gui_manager.nav.destroy].if_null[true]>
            - flag <player> gui_manager.nav.destroy:!
            - if ( <[destroy]> ):
                # |------- cache -------| #
                - define debug <player.flag[gui_manager.debug].if_null[false]>
                - define session-id <player.flag[gui_manager.session.id].if_null[null]>
                - flag <player> gui_manager.session.end:<util.time_now.format[MM/dd/yy hh:mm:ss a]>
                - flag <player> gui_manager.sessions.<[session-id]>:<player.flag[gui_manager.session].exclude[id].if_null[<map>]>
                # |------- desroy -------| #
                - flag <player> gui_manager.nav:!
                - flag <player> gui_manager.session:!
                # |------- log -------| #
                - if ( <[debug]> ):
                    - ~run gui_manager_log def.session-id:<[session-id]> save:log
                    - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
                    - define log_path <entry[log].created_queue.determination.get[1].get[2]>
                    - define message "<[log_prefix]> - end() -<&gt> session '<[session-id]>' ended."
                    - debug log <[message]>
                    - log <[message]> type:info file:<[log_path]>
                    - narrate "<&nl>current: null<&nl>next: <list><&nl>previous: <list><&nl>"



# | ----------------------------------------------  GUI MANAGER | TASKS  ---------------------------------------------- | #



gui_manager_init:
    #########################################################
    # | ---  |       initialize session task       |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  none                          --- | #
    # | ---                                           --- | #
    # | ---  Optional:  init                          --- | #
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
    definitions: init
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- initialize -------| #
        - if ( <player.open_inventory.equals[<player.inventory>]> ) && ( not <[init].if_null[false]> ) && ( <[session-id]> != null ):
            - if ( <[debug]> ):
                - define message "<[log_prefix]> - init() -<&gt> session '<[session-id]>' resumed."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>
        - else if ( <[init].if_null[false]> ) || ( <[session-id]> == null && <[init].if_null[true]> ):
            - if ( <[session-id]> != null ) && ( <[debug]> ):
                - define message "<[log_prefix]> - init() -<&gt> session '<[session-id]>' interrupted."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            # |------- set session -------| #
            - flag <player> gui_manager.nav:!
            - flag <player> gui_manager.session:!
            - flag <player> gui_manager.session.id:<util.random_uuid>
            - flag <player> gui_manager.session.start:<util.time_now.format[MM/dd/yy hh:mm:ss a]>
            - if ( <[debug]> ):
                - define log_prefix "<script[gui_manager].parsed_key[data.config.prefixes.main]> [<player.flag[gui_manager.session.id]>] <player.name>"
                - define message "<[log_prefix]> - init() -<&gt> session '<player.flag[gui_manager.session.id]>' initialized."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>
            - if ( <util.random.int[0].to[100]> == 1 ):
                - inject gui_manager_purge_logs



gui_manager_end:
    ########################################################
    # | ---  |          end session task          |  --- | #
    ########################################################
    # | ---                                          --- | #
    # | ---  Required:  none                         --- | #
    # | ---                                          --- | #
    # | ---  Optional:  session-id                   --- | #
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
    type: task
    debug: false
    definitions: session-id
    script:
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[session-id]> != null ):
            # |------- end session -------| #
            - flag <player> gui_manager.nav.destroy:true
            - inventory close



gui_manager_suspend:
    ########################################################
    # | ---  |        suspend session task        |  --- | #
    ########################################################
    # | ---                                          --- | #
    # | ---  Required:  none                         --- | #
    # | ---                                          --- | #
    # | ---  Optional:  session-id                   --- | #
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
    type: task
    debug: false
    definitions: session-id
    script:
        # |------- close gui -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[session-id]> != null ):
            - flag <player> gui_manager.nav.destroy:false
            - inventory close
            - if ( <[debug]> ):
                - ~run gui_manager_log save:log
                - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
                - define log_path <entry[log].created_queue.determination.get[1].get[2]>
                - define message "<[log_prefix]> - suspend() -<&gt> session '<player.flag[gui_manager.session.id].if_null[null]>' suspended."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>



gui_manager_open:
    #######################################################################################################
    # | ---  |                                   open gui task                                   |  --- | #
    #######################################################################################################
    # | ---                                                                                         --- | #
    # | ---  Required:  none                                                                        --- | #
    # | ---                                                                                         --- | #
    # | ---  Optional:  session-id | prefix | gui-id | page | ignore | init | build | cache-reset   --- | #
    # | ---             index | title | size | contents | list | fill | auto-title                  --- | #
    # | ---                                                                                         --- | #
    #######################################################################################################
    # | ---                                                                                         --- | #
    # | ---  Returns:  bool                                                                         --- | #
    # | ---                                                                                         --- | #
    #######################################################################################################
    # | ---                                                                                         --- | #
    # | ---  Run: true | Await: true | Inject: false                                                --- | #
    # | ---                                                                                         --- | #
    #######################################################################################################
    type: task
    debug: false
    definitions: session-id | prefix | gui-id | page | ignore | init | build | cache-reset | index | title | size | contents | list | fill | auto-title | context
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - define missing-id <[gui-id].exists.and[<[gui-id].equals[null].not>].if_true[false].if_false[true]>
        - define missing-page <[page].exists.and[<[page].equals[null].not>].if_true[false].if_false[true]>
        - define id-type <[missing-id].if_true[null].if_false[<[gui-id].object_type>]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- initialize -------| #
        - inject gui_manager_init
        # |------- parse -------| #
        - if ( not <[missing-id]> ):
            - ~run gui_manager_validate def.gui-id:<[gui-id]> save:validated
            - define gui-id <entry[validated].created_queue.determination.get[1].if_null[null]>
            - if ( <[gui-id]> == null ):
                - if ( <[debug]> ):
                    # |------- missing parameter 'gui-id' (null) -------| #
                    - define message "<[log_prefix]> - open() -<&gt> could not locate any valid gui-id target(s)."
                    - debug log <[message]>
                    - log <[message]> type:info file:<[log_path]>
                - determine false
        # |------- paginate -------| #
        - ~run gui_manager_paginate def.build:<[build].if_null[true]> def.gui-id:<[gui-id].if_null[null]> def.page:<[page].if_null[null]> def.ignore:<[ignore].if_null[false]> def.cache-reset:<[cache-reset].if_null[false]> def.context:<[context].if_null[self]> save:target
        - define target <entry[target].created_queue.determination.get[1].if_null[null]>
        - if ( <[target]> == null ):
            - determine false
        # |------- update -------| #
        - ~run gui_manager_update def.gui-id:<[id-type].contains_any_text[map|list].if_true[<[gui-id]>].if_false[<[target]>]> def.prefix:<[prefix].if_null[null]> def.index:<[index].if_null[null]> def.title:<[title].if_null[null]> def.size:<[size].if_null[null]> def.contents:<[contents].if_null[null]> def.list:<[list].if_null[null]> def.fill:<[fill].if_null[null]> def.auto-title:<[auto-title].if_null[true]> def.context:<[context].if_null[self]> save:validated
        - define inventory <entry[validated].created_queue.determination.get[1].if_null[null]>
        - if ( <[inventory]> == null ):
            - determine false
        # |------- open -------| #
        - flag <player> gui_manager.nav.destroy:false
        - playsound <player> sound:<script[gui_manager].data_key[data.config.sounds].get[left-click-button]> pitch:1
        - inventory open destination:<[inventory]>
        - flag <player> gui_manager.nav.destroy:!
        - if ( <[debug]> ):
            - if ( <player.flag[gui_manager.session.data.<[target]>.pages].size.if_null[1]> > 1 ):
                - define message "<[log_prefix]> - <[page].substring[1,4].if_null[open]>() -<&gt> '<[target]>_<player.flag[gui_manager.session.data.<[target]>.index].if_null[1]>' opened."
            - else:
                - define message "<[log_prefix]> - <[page].substring[1,4].if_null[open]>() -<&gt> '<[target]>' opened."
            - debug log <[message]>
            - narrate "<&nl>current: <player.flag[gui_manager.nav.current].if_null[null]><&nl>next: <player.flag[gui_manager.nav.next].if_null[<list>]><&nl>previous: <player.flag[gui_manager.nav.previous].if_null[<list>]><&nl>"
            - log <[message]> type:info file:<[log_path]>
        - determine true



gui_manager_paginate:
    #######################################################################################
    # | ---  |                           paginate task                           |  --- | #
    #######################################################################################
    # | ---                                                                         --- | #
    # | ---  Required:  none                                                        --- | #
    # | ---                                                                         --- | #
    # | ---  Optional:  session-id | gui-id | page | ignore | build | cache-reset   --- | #
    # | ---                                                                         --- | #
    #######################################################################################
    # | ---                                                                         --- | #
    # | ---  Returns:  str                                                          --- | #
    # | ---                                                                         --- | #
    #######################################################################################
    # | ---                                                                         --- | #
    # | ---  Run: true | Await: true | Inject: false                                --- | #
    # | ---                                                                         --- | #
    #######################################################################################
    type: task
    debug: false
    definitions: session-id | gui-id | page | ignore | build | cache-reset | context
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - define missing-id <[gui-id].exists.and[<[gui-id].equals[null].not>].if_true[false].if_false[true]>
        - define missing-page <[page].exists.and[<[page].equals[null].not>].if_true[false].if_false[true]>
        - define id-type <[missing-id].if_true[null].if_false[<[gui-id].object_type>]>
        - define page-type <[missing-page].if_true[null].if_false[<[page].object_type>]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- session data -------| #
        - ~run gui_manager_get_root def.gui-id:<[gui-id].if_null[null]> def.ignore:<[ignore].if_null[false]> save:root
        - define root <entry[root].created_queue.determination.get[1].if_null[null]>
        - define current <player.flag[gui_manager.nav.current].if_null[<[root]>]>
        - define next-cache <player.flag[gui_manager.nav.next].if_null[<list>]>
        - define previous-cache <player.flag[gui_manager.nav.previous].if_null[<list>]>
        - define blacklist <player.flag[gui_manager.session.blacklist].if_null[<list>]>
        - define blacklisted <[blacklist].contains[<[current]>].if_null[false]>
        - define built <player.flag[gui_manager.session.built].if_null[<list>]>
        - define rooted <[current].equals[<[root]>]>
        # |------- validate -------| #
        - if ( <[current]> != null ) && ( <[missing-page]> && <[missing-id]> ):
            # |------- default -------| #
            - define gui-id <[current]>
            - define missing-id false
            - define id-type element
        - else if ( <[missing-id]> ) && ( <[missing-page]> ):
            - if ( <[debug]> ):
                - define message "<[log_prefix]> - paginate() -<&gt> task requires either a gui to be opened, or a 'gui-id' or 'page' string to target."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine <[gui-id]>
            #- determine null
        - if ( not <[missing-id]> ) && ( <[context].if_null[null]> != self ):
            # |------- validate id(s) -------| #
            - ~run gui_manager_validate def.gui-id:<[gui-id]> save:validated
            - define gui-id <entry[validated].created_queue.determination.get[1].if_null[null]>
        # |------- parse target -------| #
        - if ( not <[missing-id]> ):
            # |------- type check -------| #
            - if ( <[id-type].equals[map]> ) || ( <[id-type].equals[list]> ):
                - define ids <[gui-id].keys.exists.if_true[<[gui-id].keys>].if_false[<[gui-id]>]>
                - define gui-id <[ids].last.if_null[null]>
                - define id-type <[gui-id].object_type>
                - if ( <[current]> == null ) && ( <[next-cache].include[<[previous-cache]>].is_empty> ):
                    - define blacklisted <[blacklist].contains[<[gui-id]>].if_null[false]>
                    - define previous-cache <[ids].exclude[<[gui-id]>]>
                    - define next-cache <[ids].exclude[<[ids].first>]>
                    - flag <player> gui_manager.nav.previous:<[previous-cache]>
                    - flag <player> gui_manager.nav.next:<[next-cache]>
                    - if ( <[ignore].if_null[false]> ) && ( not <[blacklisted]> ):
                        - flag <player> gui_manager.session.blacklist:->:<[gui-id]>
                        - define blacklist:->:<[gui-id]>
                    - if ( <[blacklisted]> ):
                        - define ids <[ids].exclude[<[gui-id]>]>
                    - define built:|:<[ids]>
                    - flag <player> gui_manager.session.built:<[ids]>
                    - flag <player> gui_manager.nav.current:<[gui-id]>
                    - define current <[gui-id]>
                    # |------- build -------| #
                    - if ( not <[ids].is_empty> ):
                        - ~run gui_manager_build def.gui-id:<[ids]>
                    - determine <[gui-id]>
            - if ( not <[id-type].equals[element]> ):
                - if ( <[debug]> ):
                    - define message "<[log_prefix]> - paginate() -<&gt> failed to paginate '<[id-type].to_lowercase>'. gui-id must be of type string, list or map."
                    - debug log <[message]>
                    - log <[message]> type:severe file:<[log_path]>
                - if ( <[missing-page]> ):
                    - determine null
                - define missing-id true
            - else if ( <[previous-cache]> contains <[gui-id]> ):
                # |------- page-id -------| #
                - define parsed <element[previous_<[previous-cache].get[<[previous-cache].find[<[gui-id]>]>].to[<[previous-cache].find[<[previous-cache].last>]>]>].size.if_null[1].split[_]>
                - if ( <[parsed].last.is_integer> ):
                    - define page-index <[parsed].last>
                - else:
                    - define page-index 1
                - define page <[parsed].first.if_null[<[parsed].last>]>
                - narrate "detected: <[parsed].separated_by[_]>"
            - else if ( <[current]> != <[gui-id]> ) && ( <[next-cache]> contains <[gui-id]> ):
                # |------- page-id -------| #
                - define index-current <[next-cache].find[<[current]>].equals[-1].if_true[1].if_false[<[next-cache].find[<[current]>]>]>
                - define index-target <[next-cache].find[<[gui-id]>].equals[-1].if_true[1].if_false[<[next-cache].find[<[gui-id]>]>]>
                - define valid <[index-target].is_more_than[<[index-current]>]>
                - if ( <[valid]> && not <[rooted]> && <[index-current].mod[<[index-target]>]> != 1 ) || ( <[valid]> && <[rooted]> ):
                    - define parsed <element[next_<[next-cache].get[<[index-current]>].to[<[index-target]>].size.if_null[1]>].split[_]>
                    - if ( <[parsed].last.is_integer> ):
                        - define page-index <[parsed].last>
                    - else:
                        - define page-index 1
                    - define page <[parsed].first.if_null[<[parsed].last>]>
                    - narrate "detected: <[parsed].separated_by[_]>"
        - if ( <[missing-id]> ) && ( not <[missing-page]> ):
            - define parsable <[page].replace_text[regex:<&sp>|-].with[_].if_null[<[page]>]>
            - define parsed <[parsable].split[_].if_null[<list>]>
            - if ( <[parsed].last.is_integer> ):
                - define page-index <[parsed].last>
                - define page <[parsed].first>
            - else:
                - define page-index 1
            - if ( not <list[next|prev|previous].contains[<[page]>]> ):
                - if ( <[debug]> ):
                    # |------- invalid page -------| #
                    - define message "<[log_prefix]> - open() -<&gt> page '<[page]>' is not a valid keyword."
                    - debug log <[message]>
                    - log <[message]> type:warning file:<[log_path]>
                - determine null
        # |------- validate target -------| #
        - choose <[page].if_null[null]>:
            - case next:
                # |------- next-cache -------| #
                - if ( <[next-cache]> contains <[current]> ):
                    - define cached <[next-cache].exclude[<[previous-cache].include[<[current]>]>].get[1].to[<[page-index].if_null[1]>].if_null[<list>]>
                - else:
                    - define cached <[next-cache].get[1].to[<[page-index]>].if_null[<list>]>
                - define target <[cached].last.if_null[null]>
            - case previous prev:
                # |------- previous-cache -------| #
                - define removed <[previous-cache].reverse.get[1].to[<[page-index].if_null[1]>].reverse.if_null[<list>]>
                - define cached <[previous-cache].reverse.remove[1].to[<[page-index].if_null[1]>].reverse.if_null[<list>]>
                - define target <[removed].first.if_null[null]>
            - default:
                # |------- default -------| #
                - define target <[gui-id]>
        # |------- paginate target -------| #
        - define blacklisted-target <[blacklist].contains[<[target]>].if_null[false]>
        #- narrate "root: <[root]><&nl>current: <[current]><&nl>gui-id: <[gui-id].size.if_null[<[gui-id]>]><&nl>page: <[page]><&nl>page-index: <[page-index].if_null[null]><&nl>target: <[target].if_null[null]>"
        - if ( <[target].if_null[null]> == null ):
            - if ( <[cached].is_empty> ) && ( not <player.open_inventory.equals[<player.inventory>]> ):
                # |------- close gui -------| #
                - playsound <player> sound:<script[gui_manager].data_key[data.config.sounds].get[left-click-button]> pitch:1
                - inject gui_manager_end
            - determine null
        - else:
            # |------- blacklist target -------| #
            - if ( not <[blacklisted-target]> ) && ( <[ignore].if_null[false]> ):
                - flag <player> gui_manager.session.blacklist:->:<[target]>
                - define blacklist:->:<[target]>
                - define blacklisted-target true
            # |------- adjust -------| #
            - choose <[page].if_null[null]>:
                - case next:
                    - if ( not <[blacklisted-target]> ):
                        - if ( not <[blacklisted]> ) && ( not <[previous-cache].contains[<[current]>]> ):
                            - flag <player> gui_manager.nav.previous:->:<[current]>
                            - define previous-cache:->:<[current]>
                        - if ( <[page-index]> > 1 ):
                            - foreach <[cached].exclude[<[target]>]> as:id:
                                - if ( not <[previous-cache].contains[<[id]>]> ) && ( not <[blacklist].contains[<[id]>]> ):
                                    - flag <player> gui_manager.nav.previous:->:<[id]>
                                    - define previous-cache:->:<[id]>
                                - else if ( <[debug]> ):
                                    - define message "<[log_prefix]> - next() -<&gt> '<[id]>' already found in previous cache."
                                    - debug log <[message]>
                                    - log <[message]> type:warning file:<[log_path]>
                - case previous prev:
                    - if ( not <[blacklisted-target]> ) && ( <[current]> != <[root]> ) && ( <[cached].exists> ):
                        - flag <player> gui_manager.nav.previous:!|:<[cached]>
                        - define previous-cache:!|:<[cached]>
                        - if ( not <[next-cache].contains[<[current]>]> ) && ( not <[blacklisted]> ):
                            - flag <player> gui_manager.nav.next:->:<[current]>
                            - define next-cache:->:<[current]>
                - default:
                    - if ( not <[blacklisted-target]> ):
                        - if ( <[rooted]> ) && ( <[target]> != <[next-cache].get[1].if_null[null]> ):
                            - flag <player> gui_manager.nav.next:!|:<list>
                            - define next-cache:!|:<list>
                        - if ( <[current]> != null ) && ( <[current]> != <[root]> ):
                            - if ( not <[next-cache].contains[<[current]>]> ) && ( not <[blacklisted]> ):
                                - flag <player> gui_manager.nav.next:->:<[current]>
                                - define next-cache:->:<[current]>
                        - if ( <[target]> != <[root]> ) && ( <[current]> != null ) && ( <[current]> != <[target]> ):
                            - if ( not <[previous-cache].contains[<[current]>]> ) && ( not <[blacklisted]> ) :
                                - flag <player> gui_manager.nav.previous:->:<[current]>
                                - define previous-cache:->:<[current]>
                            - if ( <[built].any> ) && ( not <[next-cache].contains[<[target]>]> ):
                                - if ( <[next-cache].any> ):
                                    - ~run gui_manager_get_parent def.gui-id:<[next-cache].last> save:check-relative
                                    - if ( <entry[check-relative].created_queue.determination.get[1].if_null[<[current]>]> == <[previous-cache].last.if_null[null]> ):
                                        - flag <player> gui_manager.nav.next:<-:<[next-cache].last>
                                        - define next-cache:<-:<[next-cache].last>
                                - flag <player> gui_manager.nav.next:->:<[target]>
                                - define next-cache:->:<[target]>
            # |------- success -------| #
            - if ( <[cache-reset].if_null[false]> ):
                # |------- reset next-cache -------| #
                - define current-index <[next-cache].find[<[target]>]>
                - define last-index <[next-cache].find[<[next-cache].last.if_null[<[current-index]>]>]>
                - if ( <[next-cache].size> > 1 ) && ( <[last-index]> > <[current-index]> ):
                    - define next-cache <[next-cache].remove[<[current-index].add[1]>].to[<[last-index]>].if_null[null]>
                    - flag player gui_manager.nav.next:<[next-cache]>
            # |------- build -------| #
            - if ( not <[blacklisted-target]> ):
                - if ( not <[built].contains[<[target]>]> ) && ( <[build].if_null[true]> ):
                    - ~run gui_manager_build def.gui-id:<[target]>
                - flag <player> gui_manager.nav.current:<[target]>
                - define current <[target]>
            - determine <[target]>



gui_manager_update:
    #######################################################################
    # | ---  |                  update gui task                  |  --- | #
    #######################################################################
    # | ---                                                         --- | #
    # | ---  Required:  gui-id                                      --- | #
    # | ---                                                         --- | #
    # | ---  Optional:  session-id | prefix | index | title | size  --- | #
    # | ---             contents | list | fill | auto-title         --- | #
    # | ---                                                         --- | #
    #######################################################################
    # | ---                                                         --- | #
    # | ---  Returns:  inventory tag | null                         --- | #
    # | ---                                                         --- | #
    #######################################################################
    # | ---                                                         --- | #
    # | ---  Run: true | Await: true | Inject: false                --- | #
    # | ---                                                         --- | #
    #######################################################################
    type: task
    debug: false
    definitions: session-id | gui-id | prefix | index | title | size | contents | list | fill | auto-title | context
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - define missing-id <[gui-id].exists.and[<[gui-id].equals[null].not>].if_true[false].if_false[true]>
        - define id-type <[missing-id].if_true[null].if_false[<[gui-id].object_type>]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- validate id(s) -------| #
        - if ( not <[missing-id]> ) && ( <[context].if_null[player]> != self ):
            # |------- validate id(s) -------| #
            - ~run gui_manager_validate def.gui-id:<[gui-id]> save:validated
            - define gui-id <entry[validated].created_queue.determination.get[1].if_null[null]>
            - define missing-id <[gui-id].exists.and[<[gui-id].equals[null].not>].if_true[false].if_false[true]>
        # |------- vaidate gui-id(s) -------| #
        - if ( <[missing-id]> ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' (null) -------| #
                - define message "<[log_prefix]> - update() -<&gt> missing parameter 'gui-id'."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - determine null
        - else if ( <[id-type].equals[map]> ) || ( <[id-type].equals[element]> && <[gui-id].starts_with[map&at].if_null[false]> ):
            - define gui-ids <[gui-id].keys.if_null[<list>]>
            - define kwargs <[gui-id].if_null[<map>]>
        - else if ( <[id-type].equals[list]> ) || ( <[id-type].equals[element]> && <[gui-id].starts_with[li&at].if_null[false]> ):
            - define gui-ids <[gui-id].if_null[<list>]>
            - define values <list.pad_right[<[gui-id].size.sub[1]>].replace[<empty>].with[<map>].include_single[<map[prefix=<[prefix].if_null[null]>;index=<[index].if_null[null]>;title=<[title].if_null[null]>;contents=<[contents].if_null[null]>;list=<[list].if_null[null]>;fill=<[fill].if_null[null]>]>]>
            - define kwargs <[gui-ids].map_with[<[values]>]>
        - else if ( <[id-type].equals[element]> ):
            - define gui-ids:->:<[gui-id]>
        # |------- adjust properties -------| #
        - foreach <[gui-ids].if_null[<list>]> as:gui-id:
            - if ( <[kwargs].exists.if_null[false]> ):
                - define args <[kwargs].get[<[gui-id]>].if_null[<map>]>
                - define prefix <[args].get[prefix].if_null[<[prefix].if_null[null]>]>
                - define index <[args].get[index].if_null[null]>
                - define title <[args].get[title].if_null[null]>
                - define size <[args].get[size].if_null[null]>
                - define contents <[args].get[contents].if_null[null]>
                - define list <[args].get[list].if_null[null]>
                - define fill <[args].get[fill].if_null[null]>
            # |------- unique object check -------| #
            - if ( <[prefix].if_null[null]> == null ):
                - define prefix <player.flag[gui_manager.nav.prefix].if_null[null]>
            - if ( <[prefix].if_null[null]> != null ):
                - define inventory <inventory[<[prefix]><[gui-id]>].if_null[null]>
                - flag <player> gui_manager.nav.prefix:<[prefix]>
            - else:
                - define inventory <inventory[<[gui-id]>].if_null[null]>
            # |------- flags -------| #
            - define existing-id <player.has_flag[gui_manager.session.data.<[gui-id]>].if_null[false]>
            - define missing-inventory <[inventory].exists.and[<[inventory].equals[null].not>].if_true[false].if_false[true]>
            - define missing-contents <[contents].exists.and[<[contents].equals[null].not>].if_true[false].if_false[true]>
            - define missing-list <[list].exists.and[<[list].equals[null].not>].if_true[false].if_false[true]>
            - define contents-type <[missing-contents].if_true[null].if_false[<[contents].object_type>]>
            - define list-type <[missing-list].if_true[null].if_false[<[list].object_type>]>
            # |------- data -------| #
            - define built <player.flag[gui_manager.session.built].if_null[<list>]>
            - define cache <player.flag[gui_manager.session.data].get[<[gui-id]>].if_null[<map>]>
            # |------- validate contents -------| #
            - if ( not <[missing-contents]> ) && ( not <[contents-type].equals[inventory]> ):
                - ~run gui_manager_validate def.contents:<[contents]> save:valid-contents
                - define contents <entry[valid-contents].created_queue.determination.get[1].if_null[null]>
                - define missing-contents <[contents].equals[null].if_true[true].if_false[false]>
                - define contents-type <[missing-contents].if_true[null].if_false[<[contents].object_type>]>
            - if ( <[contents].is_empty.if_null[true]> ):
                - define contents:!
                - define missing-contents true
            # |------- validate size -------| #
            - if ( <[size].if_null[null]> != null ) && ( not <[size].is_integer.if_null[false]> ):
                - define size:!
                - if ( <[debug]> ):
                    - define message "<[log_prefix]> - update() -<&gt> size must be of object type integer. Invalid type '<[size].object_type.to_lowercase>' ignored."
                    - debug log <[message]>
                    - log <[message]> type:warning file:<[log_path]>
            - else if ( <[size].is_integer.if_null[false]> ) && ( <[size].mod[9].if_null[1]> != 0 ):
                # |------- invalid size -------| #
                - define invalid <[size]>
                - define size <[invalid].add[<element[9].mod[<[size].mod[9]>]>].if_null[<[size]>]>
                - if ( <[size]> == <[invalid]> ):
                    - define size <[invalid].sub[<[size].mod[9].mod[9]>].if_null[<[size]>]>
                - if ( <[debug]> ):
                    - define message "<[log_prefix]> - update() -<&gt> invalid parameter input size '<[invalid]>'. Updated to '<[size]>'."
                    - debug log <[message]>
                    - log <[message]> type:warning file:<[log_path]>
            # |------- adjust inventory cache -------| #
            - if ( not <[missing-inventory]> ):
                # |------- cache unique -------| #
                - flag <player> gui_manager.session.data.<[gui-id]>.type:unique
            - else if ( <[missing-inventory]> ) && ( not <[existing-id]> ):
                - define size <[missing-contents].if_true[<[size].if_null[null].equals[null].if_true[54].if_false[<[size]>]>].if_false[<[contents].size.if_null[0].is_more_than[54].if_true[54].if_false[<[contents].size>]>]>
                - narrate "size: <[size]>"
                # |------- cache generic -------| #
                - flag <player> gui_manager.session.data.<[gui-id]>.type:generic
                - flag <player> gui_manager.session.data.<[gui-id]>.size:<[size]>
                - define inventory <inventory[generic[title=<[gui-id]>;size=<[size]>]]>
            - else if ( <[cache].get[type].if_null[null]> == generic ) || ( <[existing-id]> && <[missing-inventory]> ):
                # |------- instantiate generic -------| #
                - define cached-index <player.flag[gui_manager.session.data.<[gui-id]>.index].if_null[1]>
                - define cached-title <player.flag[gui_manager.session.data.<[gui-id]>.title].if_null[<[gui-id].replace_text[regex:_].with[<&sp>]>]>
                - define cached-size <player.flag[gui_manager.session.data.<[gui-id]>.size].if_null[null]>
                - define cached-contents <player.flag[gui_manager.session.data.<[gui-id]>.pages.<[cached-index]>].unescaped.as[list].if_null[<list>]>
                - if ( <[size].if_null[null]> != null ) && ( <[cached-size]> != <[size]> ):
                    - flag <player> gui_manager.session.data.<[gui-id]>.size:<[size]>
                    - define cached-size <[size]>
                - define inventory <inventory[generic[title=<[cached-title]>;size=<[cached-size]>;contents=<[cached-contents]>]]>
            #- if ( <[inventory].list_contents.is_empty> ) && ( <[list]> != null .if_null[ <[fill]> != null ):
                #- adjust <[inventory]> contents:<list.pad_right[<[inventory].size>].replace[<empty>].with[<item[structure_void]>]>
            # |------- adjust contents cache -------| #
            - if ( <[contents-type].equals[inventory]> ):
                - define contents <[contents].list_contents.if_null[<list>]>
                - flag <player> gui_manager.session.data.<[gui-id]>.pages.1:<[contents].escaped>
                - flag <player> gui_manager.session.data.<[gui-id]>.index:1
            - else if ( <[contents-type].equals[list]> ):
                - define pages <[contents].sub_lists[<[contents].size>].if_null[<list[<[contents]>]>]>
                - if ( <[pages].is_empty.if_null[true]> ):
                    - narrate placeholder
                - else:
                    - define pages <util.list_numbers_to[<[pages].size>].map_with[<[pages].parse_tag[<[parse_value].escaped>]>]>
                    - flag <player> gui_manager.session.data.<[gui-id]>.pages:<[pages]>
                    - flag <player> gui_manager.session.data.<[gui-id]>.index:1
            # |------- parse parameters (list & fill) -------| #
            - define cache <player.flag[gui_manager.session.data].get[<[gui-id]>].if_null[<map>]>
            - if ( not <[missing-list]> ) || ( <[fill].if_null[null]> != null ) || ( not <[missing-contents]> && <[cache].keys.contains[list]> ):
                # |------- data -------| #
                - define cached <[cache].keys.contains[pages].if_null[false]>
                - define listed <[cache].keys.contains[list].if_null[false]>
                # |------- set parameter (list) -------| #
                - if ( <[listed]> ) && ( <[list].if_null[null]> == null ):
                    - define list <[cache].get[list].unescaped.as[list].if_null[<list>]>
                - else if ( <[list].if_null[null]> == null ):
                    - define list <list>
                - if ( not <[missing-list]> ):
                    - ~run gui_manager_validate def.contents:<[list]> def.adjust-contents:false save:valid-list
                    - define list <entry[valid-list].created_queue.determination.get[1].if_null[null]>
                - if ( not <[list].object_type.equals[list]> ):
                    - define list <list>
                    - if ( <[debug]> ):
                        # |------- invalid parameter (list) -------| #
                        - define message "<[log_prefix]> - update() -<&gt> '<[gui-id]>' list must be of object type list. Object type '<[list-type].to_lowercase>' ignored."
                        - debug log <[message]>
                        - log <[message]> type:severe file:<[log_path]>
                # |------- parse contents -------| #
                - if ( <[cached]> ) && ( not <[missing-contents]> ) && ( <[list].any.exists.if_null[false]> ):
                    - define pages <[cache].get[pages].if_null[<map>]>
                    - foreach <[pages]> key:index as:page:
                        - define empty-slots <[page].find_all_matches[air].if_null[<list>]>
                        - if ( <[page].size> == <[page].list_contents.find_all_matches[structure_void].if_null[<list>].size> ):
                            - define empty-slots <util.list_numbers[to=<[inventory].size>]>
                        - if ( <[empty-slots].is_empty> ):
                            - if ( <[debug]> ):
                                # |------- null slots -------| #
                                - define message "<[log_prefix]> - update() -<&gt> inventory '<[gui-id]>_<[loop_index]>' does not contain any empty slots."
                                - debug log <[message]>
                                - log <[message]> type:warning file:<[log_path]>
                            - foreach next
                        - define page-slots:->:<[empty-slots]>
                        - define list-pages:->:<[list].get[1].to[<[empty-slots].size>].if_null[<[list].get[1].to[<[list].size>]>]>
                        - define list <[list].remove[1].to[<[empty-slots].size>].if_null[<[list].remove[1].to[<[list].size>]>]>
                    - if ( <[list].any> ):
                        # |------- handle overflow -------| #
                        - define overflow <[list].sub_lists[<[page-slots].last.size>].if_null[<list[<[list]>]>]>
                        - if ( <[overflow].is_empty> ):
                            - if ( <[debug]> ):
                                # |------- could not allocate -------| #
                                - define message "<[log_prefix]> - update() -<&gt> could not allocate '<[list].size>' list overflow. A critical size error has occurred."
                                - debug log <[message]>
                                - log <[message]> type:warning file:<[log_path]>
                        - else:
                            - define page-slots <[page-slots].include[<[overflow].filter_tag[<[filter_value].is_empty.not>].separated_by[|]>]>
                - else:
                    - define empty-slots <[inventory].list_contents.find_all_matches[air].if_null[<list>]>
                    - define list-pages <[list].sub_lists[<[empty-slots].size>].if_null[<list>]>
                    - define page-slots <util.list_numbers_to[<[list-pages].size>].replace[regex:[0-9]].with[<[empty-slots]>].if_null[<list>]>
                # |------- parse listables -------| #
                - define list:!
                - define missing-pages <[list-pages].exists.and[<[list-pages].is_empty.not>].if_true[false].if_false[true]>
                - if ( <[cached]> ) && ( not <[missing-contents]> ) && ( <[missing-pages]> ):
                    - flag <player> gui_manager.session.data.<[gui-id]>.list:!
                - else if ( not <[missing-pages]> ):
                    - flag <player> gui_manager.session.data.<[gui-id]>.list:<[list-pages].combine.escaped>
                    - foreach <[list-pages]> as:page:
                        - define empty-slots <[page-slots].get[<[loop_index]>]>
                        - if ( <[page]> == <[list-pages].last> ):
                            # |------- validate empty -------| #
                            - define last <[page]>
                            - if ( <[page].size> < <[empty-slots].size> ):
                                - if ( <[fill].if_null[null]> == null ):
                                    - define fill <item[air]>
                                - else if ( not <[fill].object_type.equals[item]> ):
                                    - if ( <[debug]> ):
                                        # |------- invalid parameter 'fill' -------| #
                                        - define message "<[log_prefix]> - update() -<&gt> fill must be of object type item."
                                        - debug log <[message]>
                                        - log <[message]> type:warning file:<[log_path]>
                                    - if ( <[list].is_empty> ):
                                        - define fill null
                                    - else:
                                        - define fill <item[air]>
                                # |------- fill empty -------| #
                                - define list-pages:<-:<[last]>
                                - define page <[last].pad_right[<[empty-slots].size>].replace[<empty>].with[<[fill]>]>
                                - define list-pages:->:<[page]>
                            # |------- final check -------| #
                            - if ( <[list-pages].size> == 1 ) && ( not <[page].any> ):
                                - if ( <[cache].get[pages].if_null[null]> != null ):
                                    - flag <player> gui_manager.session.data.<[gui-id]>.index:!
                                    - flag <player> gui_manager.session.data.<[gui-id]>.pages:!
                                    - flag <player> gui_manager.session.data.<[gui-id]>.list:!
                                - goto skip-page-caching
                        # |------- cache pages -------| #
                        - define cached_contents <player.flag[gui_manager.session.data.<[gui-id]>.pages.<[loop_index]>].unescaped.as[list].if_null[null]>
                        - if ( <[cached_contents]> == null ):
                            - define cached_contents <[inventory].list_contents>
                        - foreach <[empty-slots].map_with[<[page]>]> key:slot as:item:
                            - define cached_contents <[cached_contents].set[<[item]>].at[<[slot]>]>
                        - flag <player> gui_manager.session.data.<[gui-id]>.pages.<[loop_index]>:<[cached_contents].escaped>
                    # |------- update flags -------| #
                    - define cached-index <player.flag[gui_manager.session.data.<[gui-id]>.index].if_null[null]>
                    - if ( <[cached-index]> == null ):
                        - flag <player> gui_manager.session.data.<[gui-id]>.index:1
                    - else if ( <[cached-index].if_null[1]> > <[list-pages].size> ):
                        - flag <player> gui_manager.session.data.<[gui-id]>.index:<[cached-index].sub[<[cached-index].mod[<[list-pages].size>]>]>

            # |------- check cached properties -------| #
            - mark skip-page-caching
            - define original-title <[inventory].title.if_null[<[gui-id]>]>
            - define cache <player.flag[gui_manager.session.data].get[<[gui-id]>].if_null[<map>]>
            - if ( <[index].if_null[null]> != null ) && ( not <[cache].keys.contains[pages]> ):
                - define index:!
            - else if ( <[cache].keys.contains[pages]> ):
                # |------- page data -------| #
                - define manual <[index].if_null[null]>
                - define index <[cache].get[index].if_null[1]>
                - define pages <[cache].get[pages].if_null[<map>]>
                # |------- adjust index -------| #
                - choose <[manual].if_null[null]>:
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
                        - if ( <[manual]> != null ) && ( not <[manual].is_integer> ):
                            - if ( <[debug]> ):
                                - define message "<[log_prefix]> - update() -<&gt> gui-id '<[gui-id]>' does not recognize index keyword '<[manual]>'."
                                - debug log <[message]>
                                - log <[message]> type:warning file:<[log_path]>
                        - else if ( <[manual].is_integer> ):
                            - if ( <[manual]> >= 1 ):
                                - if ( <[manual]> > <[pages].size> ):
                                    - define index <[pages].size>
                                    - if ( <[debug]> ):
                                        # |------- max index -------| #
                                        - define message "<[log_prefix]> - update() -<&gt> gui-id '<[gui-id]>' does not contain index '<[manual]>'. Defaulting to '<[pages].size>'."
                                        - debug log <[message]>
                                        - log <[message]> type:warning file:<[log_path]>
                                - else:
                                    - define index <[manual]>
                            - else:
                                # |------- min index -------| #
                                - define index 1
                                - if ( <[debug]> ):
                                    - define message "<[log_prefix]> - update() -<&gt> gui-id '<[gui-id]>' does not contain index '<[manual]>'. Defaulting to '1'."
                                    - debug log <[message]>
                                    - log <[message]> type:warning file:<[log_path]>
                # |------- adjust contents -------| #
                - define content <[pages].get[<[index]>].unescaped.as[list].if_null[<list>]>
                - if ( <[content].is_empty> ):
                    - if ( <[debug]> ):
                        # |------- invalid content -------| #
                        - define message "<[log_prefix]> - update() -<&gt> index '<[index]>' could not be found."
                        - debug log <[message]>
                        - log <[message]> type:severe file:<[log_path]>
                - else:
                    - adjust <[inventory]> contents:<[content]>
                    - flag <player> gui_manager.session.data.<[gui-id]>.index:<[index]>
            # |------- adjust title -------| #
            - if ( <[title].if_null[null]> != null ):
                - flag <player> gui_manager.session.data.<[gui-id]>.title:<[title].if_null[null]>
            - else if ( <[cache].get[title].if_null[null]> != null ):
                - define title <[cache].get[title].if_null[null]>
            - else:
                - define title <[original-title]>
            - if ( <[gui-id]> == <[gui-ids].last> ):
                - if ( <[auto-title].if_null[true]> ) && ( <[index].if_null[null]> != null ) && ( <[pages].size.if_null[1]> > 1 ) && ( <[index].is_integer> ):
                    - adjust <[inventory]> title:<[title]><&sp>-<&sp><[index]>
                - else if ( <[inventory].title> != <[title]> ):
                    - adjust <[inventory]> title:<[title]>
                - define updated <[inventory]>
        # |------- return instantiated inventory -------| #
        - determine <[updated].if_null[null]>



gui_manager_validate:
    type: task
    debug: false
    definitions: session-id | gui-id | contents | escaped | adjust-contents | adjust-gui-id
    script:
        ##########################################################
        # | ---  |              parse task              |  --- | #
        ##########################################################
        # | ---                                            --- | #
        # | ---  Required:  gui-id(s)                      --- | #
        # | ---                                            --- | #
        # | ---  Optional:  none                           --- | #
        # | ---                                            --- | #
        ##########################################################
        # | ---                                            --- | #
        # | ---  Returns:  str | list | map | null         --- | #
        # | ---                                            --- | #
        ##########################################################
        # | ---                                            --- | #
        # | ---  Run: true | Await: true | Inject: false   --- | #
        # | ---                                            --- | #
        ##########################################################
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - define missing-id <[gui-id].exists.and[<[gui-id].equals[null].not>].if_true[false].if_false[true]>
        - define missing-contents <[contents].exists.and[<[contents].equals[null].not>].if_true[false].if_false[true]>
        - define id-type <[missing-id].if_true[null].if_false[<[gui-id].object_type>]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- parameter check -------| #
        - if ( <[missing-id]> ) && ( <[missing-contents]> ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' (null) -------| #
                - define message "<[log_prefix]> - validate() -<&gt> task requires 'gui-id' or 'contents' data to validate."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine null
        - else if ( not <[missing-id]> ) && ( not <[missing-contents]> ):
            - define id_index <queue.definitions.find[gui-id].if_null[1]>
            - define content_index <queue.definitions.find[contents].if_null[<[id_index]>]>
            - if ( <[id_index]> > <[content_index]> ):
                - define exe_order <list[contents|gui-id]>
            - else if ( <[id_index]> != <[content_index]> ):
                - define exe_order <list[gui-id|contents]>
        # |------- validate (contents) -------| #
        - if ( not <[missing-contents]> ):
            #- define filtered <[contents].filter_tag[<[filter_value].object_type.equals[list].or[<[filter_value].object_type.equals[element].and[<[filter_value].starts_with[li&at].if_null[false>]>]>].if_null[<list>>
            - define filtered <list.include[<[contents].first.if_null[null]>|<[contents].last.if_null[null]>].filter_tag[<[filter_value].object_type.equals[list].or[<[filter_value].object_type.equals[element].and[<[filter_value].starts_with[li&at].if_null[false]>]>]>].if_null[<list>]>
            - if ( <[filtered].is_empty> ):
                - define parsable:->:<[contents]>
                - define arg-type single
            - else:
                - define parsable <[filtered]>
                - define arg-type list
            - foreach <[parsable]> as:content:
                - define contents-type <[contents].object_type>
                - if ( <[contents-type].equals[element]> ) && ( <[content].starts_with[li&at].if_null[false]> ):
                    - define content <[content].unescaped.as[list]>
                    - define contents-type list
                - if ( not <[contents-type].equals[list]> ):
                    # |------- invalid type -------| #
                    - define message "<[log_prefix]> - validate() -<&gt> contents must be of type list. Object type '<[contents-type].to_lowercase>' ignored."
                    - debug log <[message]>
                    - log <[message]> type:severe file:<[log_path]>
                    - foreach next
                - else if ( <[content].is_empty.if_null[true]> ):
                    - if ( <[debug]> ):
                        # |------- empty contents -------| #
                        - define message "<[log_prefix]> - validate() -<&gt> contents are empty. Object type 'empty list' ignored."
                        - debug log <[message]>
                        - log <[message]> type:severe file:<[log_path]>
                    - foreach next
                - define valid <[content].filter_tag[<[filter_value].object_type.equals[item]>].if_null[<list>]>
                - if ( <[debug]> ) && ( <[valid].size> != <[content].size> ):
                    - define invalid <[content].filter_tag[<[filter_value].object_type.equals[item].not>].if_null[<list>]>
                    - if ( <[invalid].any> ):
                        # |------- invalid found -------| #
                        - define message "<[log_prefix]> - validate() -<&gt> removed '<[invalid].size>' items from contents list. Parameter 'contents' must be a list of item objects."
                        - debug log <[message]>
                        - log <[message]> type:warning file:<[log_path]>
                # |------- cache contents -------| #
                - if ( <[adjust-contents].if_null[true]> ) && ( <[valid].size.mod[9]> != 0 ) && ( <[valid].size> > 9 ):
                    # |------- invalid contents size -------| #
                    - define invalid <[valid].size>
                    - define contrast <element[9].mod[<[invalid].mod[9]>]>
                    - if ( <[contrast]> != 0 ):
                        - define valid <[valid].pad_right[<[contrast]>].replace[<empty>].with[<item[air]>].if_null[<[valid]>]>
                    - else:
                        - define contrast <[invalid].mod[9].mod[9]>
                        - define valid <[valid].reverse.remove[<util.list_numbers_to[<[contrast]>].separated_by[|]>].reverse>
                - if ( <[valid].any> ):
                    - if ( <[escaped].if_null[false]> ):
                        - define valid <[valid].escaped>
                    - define valid-contents:->:<[valid]>
            - if ( <[valid-contents].size.if_null[1]> == 1 ) && ( <[arg-type]> == single ):
                - define valid-contents <[valid-contents].last.if_null[<[parsable].last>]>
            - else:
                - define valid-contents <[valid-contents].if_null[null]>
        # |------- validate (gui-id) -------| #
        - if ( <[id-type].equals[map]> ) || ( <[id-type].equals[list]> ):
            - if ( <[id-type].equals[map]> ):
                # |------- parse gui-ids -------| #
                - define filtered <[gui-id].filter_tag[<[filter_value].object_type.equals[map].and[<[filter_key].object_type.equals[element].and[<[filter_key].equals[null].not.and[<[filter_key].is_integer.not.and[<[filter_key].is_boolean.not>]>]>]>]>].if_null[<map>]>
                - define valid <[filtered].keys.parse_tag[<[parse_value].replace_text[regex:<&sp>|-].with[_]>].if_null[<[filtered].keys>].map_with[<[filtered].values>].as[map]>
                - if ( <[debug]> ) && ( <[valid].keys.size> != <[gui-id].keys.size> ):
                    - define invalid <[gui-id].filter_tag[<[filter_value].object_type.equals[map].not.or[<[filter_key].object_type.equals[element].not.or[<[filter_key].equals[null].or[<[filter_key].is_integer.or[<[filter_key].is_boolean>]>]>]>]>].if_null[<map>]>
                    - foreach <[invalid]> key:invalid-id as:invalid-value:
                        # |------- log invalid -------| #
                        - define id-type <[invalid-id].object_type>
                        - define value-type <[invalid-value].object_type>
                        - if ( not <[id-type].equals[element].if_null[false]> ) && ( not <[value-type].equals[map].if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id must be of type string and args must be of type map. Object type '<[id-type].to_lowercase>' and '<[value-type].to_lowercase>' ignored."
                        - else if ( not <[id-type].equals[element].if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id must be of type string. Object type '<[id-type].to_lowercase>' ignored."
                        - else if ( <[invalid-id].is_integer.if_null[false]> ) && ( not <[value-type].equals[map].if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string and args must be of type map. Object type 'integer' and '<[value-type].to_lowercase>' ignored."
                        - else if ( <[invalid-id].is_integer.if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string. Object type 'integer' ignored."
                        - else if ( <[invalid-id].is_boolean.if_null[false]> ) && ( not <[value-type].equals[map].if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string and args must be of type map. Object type 'integer' and '<[value-type].to_lowercase>' ignored."
                        - else if ( <[invalid-id].is_boolean.if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string. Object type 'boolean' ignored."
                        - debug log <[message]>
                        - log <[message]> type:warning file:<[log_path]>
                # |------- validate values -------| #
                - foreach <[valid].deep_keys.deduplicate.filter_tag[<[filter_value].split[.].last.contains_any[contents|list].if_null[false]>].if_null[<list>]> as:kwarg:
                    - define parsable <[valid].deep_get[<[kwarg]>]>
                    - if ( <[parsable].object_type.equals[list]> ):
                        - define valid.<[kwarg]>:<[parsable].escaped>
            - else:
                # |------- parse list -------| #
                - define valid <[gui-id].filter_tag[<[filter_value].object_type.equals[element].and[<[filter_value].equals[null].not.and[<[filter_value].is_integer.not.and[<[filter_value].is_boolean.not>]>]>]>].parse_tag[<[parse_value].replace_text[regex:<&sp>|-].with[_]>].as[list].if_null[<list>]>
                - if ( <[debug]> ) && ( <[valid].size> != <[gui-id].size> ):
                    - define invalid <[gui-id].filter_tag[<[filter_value].object_type.equals[element].not.or[<[filter_value].equals[null].or[<[filter_value].is_integer.or[<[filter_value].is_boolean>]>]>]>].if_null[<list>]>
                    - foreach <[invalid]> as:invalid-id:
                        # |------- log invalid -------| #
                        - if ( not <[invalid-id].object_type.equals[element].if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id must be of type string. Object type '<[invalid-id].object_type.to_lowercase>' ignored."
                        - else if ( <[invalid-id].is_integer.if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string. Object type 'integer' ignored."
                        - else if ( <[invalid-id].is_boolean.if_null[false]> ):
                            - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[invalid-id]>' must be of type string. Object type 'boolean' ignored."
                        - debug log <[message]>
                        - log <[message]> type:warning file:<[log_path]>
            - if ( <[valid].is_empty> ):
                # |------- invalid (null) -------| #
                - define message "<[log_prefix]> - validate() -<&gt> found '<[gui-id].size>' invalid gui-id(s)."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - else if ( <[valid].object_type.equals[map]> ):
                # |------- valid (list) -------| #
                - define valid-ids:->:<[valid].as[map]>
            - else:
                # |------- valid (list) -------| #
                - define valid-ids:->:<[valid].as[list]>
        - else if ( not <[missing-id]> ):
            # |------- valid (str) -------| #
            - if ( <[debug]> ) && ( not <[id-type].equals[element].if_null[false]> ):
                - define message "<[log_prefix]> - validate() -<&gt> gui-id must be of type string. Object type '<[id-type].to_lowercase>' ignored."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - else if ( <[debug]> ) && ( <[gui-id].is_integer.if_null[false]> ):
                - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[gui-id]>' must be of type string. Object type 'integer' ignored."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - else if ( <[debug]> ) && ( <[gui-id].is_boolean.if_null[false]> ):
                - define message "<[log_prefix]> - validate() -<&gt> gui-id '<[gui-id]>' must be of type string. Object type 'boolean' ignored."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - else if ( <[gui-id].object_type.equals[element]> ):
                - define valid-ids:->:<[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        # |------- determine -------| #
        - define missing-valid-ids <[valid-ids].if_null[null].equals[null].if_null[true]>
        - define missing-valid-contents <[valid-contents].if_null[null].equals[null].if_null[true]>
        - if ( <[valid-ids].size.if_null[0]> == 1 ):
            - define valid-ids <[valid-ids].last>
        - if ( <[exe_order].last.if_null[null]> == contents ) && ( not <[missing-valid-ids]> ) && ( not <[missing-valid-contents]> ):
            - define valid-data:->:<[valid-ids]>
            - define valid-data:->:<[valid-contents]>
        - else if ( <[exe_order].last.if_null[null]> == gui-id ) && ( not <[missing-valid-ids]> ) && ( not <[missing-valid-contents]> ):
            - define valid-data:->:<[valid-contents]>
            - define valid-data:->:<[valid-ids]>
        - else if ( <[exe_order].exists> ) && ( not <[missing-valid-ids]> ) && ( <[missing-valid-contents]> ):
            - define valid-data <[valid-ids]>
        - else if ( <[exe_order].exists> ) && ( not <[missing-valid-contents]> ) && ( <[missing-valid-ids]> ):
            - define valid-data <[valid-contents]>
        - else if ( <[valid-ids].if_null[null]> != null ):
            - define valid-data <[valid-ids]>
        - else if ( <[valid-contents].if_null[null]> != null ):
            - define valid-data <[valid-contents]>
        - determine <[valid-data].if_null[null]>



gui_manager_build:
    ##########################################################
    # | ---  |              build task              |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  gui-id(s)                      --- | #
    # | ---                                            --- | #
    # | ---  Optional:  parent-id                      --- | #
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
    definitions: session-id | gui-id | parent-id
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- check multi -------| #
        - if ( <[gui-id].any.exists.if_null[false]> ):
            - define parsed <[gui-id].parse_tag[<[parse_value].replace_text[regex:<&sp>|-].with[_].if_null[<[parse_value]>]>].if_null[<list>]>
            - flag <player> gui_manager.session.ast.<[parsed].separated_by[.]>:<empty>
            - flag <player> gui_manager.session.built:|:<[parsed]>
            - if ( <[debug]> ):
                - define message "<[log_prefix]> - build() -<&gt> built '<[parsed].separated_by[.]>' to ast."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>
            - determine true
        # |------- ast data -------| #
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - define parent-id <[parent-id].replace_text[regex:<&sp>|-].with[_].if_null[<[parent-id].if_null[null]>]>
        - if ( <[parent-id]> == null ):
            - define parent-id <player.flag[gui_manager.nav.previous].last.if_null[<player.flag[gui_manager.nav.current].if_null[null]>]>
            - if ( <[parent-id]> == null ):
                - flag <player> gui_manager.session.ast.<[gui-id]>:<empty>
                - goto built
        - define filtered <[ast].deep_keys.filter_tag[<[filter_value].split[.].contains[<[parent-id]>]>].include[<[ast].keys.filter_tag[<[filter_value].equals[<[parent-id]>]>]>]>
        - define parsed <[filtered].parse_tag[<[parse_value].split[.].get[1].to[<[parse_value].split[.].find[<[parent-id]>]>]>].deduplicate>
        - if ( <[parsed].size> > 1 ):
            - if ( <[debug]> ):
                # |------- maximum -------| #
                - define message "<[log_prefix]> - build() -<&gt> gui '<[gui-id]>' found too many parent nodes and is limited to one (1)."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[parsed].is_empty> ):
            - flag <player> gui_manager.session.ast.<[gui-id]>:<empty>
            - goto built
        - define branch <[parsed].get[1].separated_by[.]>
        - flag <player> gui_manager.session.ast.<[branch]>.<[gui-id]>:<empty>
        - mark built
        # |------- success -------| #
        - flag <player> gui_manager.session.built:->:<[gui-id]>
        - if ( <[debug]> ):
            - define message "<[log_prefix]> - build() -<&gt> built '<[gui-id]>' to ast."
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>
        - determine true



# | ----------------------------------------------  GUI MANAGER | UTILITY TASKS  ---------------------------------------------- | #



gui_manager_get_version:
    #########################################################
    # | ---  |             get version             |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  none                          --- | #
    # | ---                                           --- | #
    # | ---  Optional:  none                          --- | #
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
    script:
        - define version <script[gui_manager].data_key[data.version].if_null[null]>
        - if ( <[version]> != null ):
            - determine <[version]>
        - else:
            - narrate "version could not be located."
            - determine false



gui_manager_log:
    ##########################################################
    # | ---  |             get log data             |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  none                           --- | #
    # | ---                                            --- | #
    # | ---  Optional:  none                           --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Returns:  list                            --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Run: true | Await: true | Inject: false   --- | #
    # | ---                                            --- | #
    ##########################################################
    type: task
    debug: false
    definitions: session-id | prefix | path
    script:
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - define log_dir <script[gui_manager].parsed_key[data.config.log.dir].split[/].separated_by[/].if_null[<script[gui_manager].parsed_key[data.config.log.dir]>].if_null[plugins/Denizen/data/logs/gui_manager]>
        - if ( <[log_dir].ends_with[/]> ):
            - define log_dir <[log_dir].before_last[/].if_null[<[log_dir]>]>
        - define log_path <[log_dir]>/<util.time_now.format[MM-dd-yyyy]>.txt
        - define log_prefix <element[<script[gui_manager].parsed_key[data.config.prefixes.main].if_null[null]> [<[session-id]>] <player.name>]>
        - if ( <[prefix].if_null[false]> ) && ( not <[path].if_null[false]> ):
            - define log-data <[log_prefix].if_null[null]>
        - else if ( <[path].if_null[false]> ) && ( not <[prefix].if_null[false]> ):
            - define log-data <[log_path].if_null[null]>
        - else:
            - define log-data <list.include[<[log_prefix]>|<[log_path]>].if_null[<list>]>
        - determine <[log-data]>


gui_manager_purge_logs:
    ########################################################
    # | ---  |             purge logs             |  --- | #
    ########################################################
    # | ---                                          --- | #
    # | ---  Required:  none                         --- | #
    # | ---                                          --- | #
    # | ---  Optional:  none                         --- | #
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
    definitions: session-id
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- parse -------| #
        - if ( <[debug]> ):
            - define message "<[log_prefix]> - purge() -<&gt> purge triggered. Gathering logs..."
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>
        - define dir <script[gui_manager].parsed_key[data.config.log.dir].if_null[plugins/Denizen/data/logs/gui_manager/].split[/].separated_by[/]>
        - define path <[dir].after[denizen/]>
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
                    - adjust system delete_file:<[path]>/<[log]>
                - if ( <[debug]> ):
                    - if ( <[amount]> > 1 ):
                        - define message "<[log_prefix]> - purge() -<&gt> '<[amount]>' logs purged."
                    - else:
                        - define message "<[log_prefix]> - purge() -<&gt> '<[amount]>' log purged."
                    - if ( <player.flag[gui_manager.debug]> ):
                        - debug log <[message]>
                        - log <[message]> type:info file:<[log_path]>
            - else if ( <[debug]> ):
                # |------- cancel -------| #
                - if ( <[amount]> > 1 ):
                    - define message "<[log_prefix]> - purge() -<&gt> purge cancelled. '<[logs].size>' logs found."
                - else:
                    - define message "<[log_prefix]> - purge() -<&gt> purge cancelled. '<[logs].size>' log found."
                - debug log <[message]>
                - log <[message]> type:info file:<[log_path]>



gui_manager_get_slot:
    ##########################################################
    # | ---  |               get slot               |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  slot                           --- | #
    # | ---                                            --- | #
    # | ---  Optional:  contents                       --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Returns:  str | bool                      --- | #
    # | ---                                            --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Run: true | Await: true | Inject: false   --- | #
    # | ---                                            --- | #
    ##########################################################
    type: task
    debug: false
    definitions: slot | contents
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - define prefix <player.flag[gui_manager.nav.prefix].if_null[null]>
        - define missing-slot <[slot].exists.and[<[slot].equals[null].not>].if_true[false].if_false[true]>
        - define missing-contents <[contents].exists.and[<[contents].equals[null].not>].if_true[false].if_false[true]>
        - define slot-type <[missing-slot].if_true[null].if_false[<[slot].object_type>]>
        - define contents-type <[missing-contents].if_true[null].if_false[<[contents].object_type>]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- parse contents -------| #
        - if ( <[missing-contents]> ):
            - define current <player.flag[gui_manager.nav.current].if_null[null]>
            - if ( <[current]> == null ):
                - goto contents-check
            - define contents <[current]>
            - define missing-contents false
            - define contents-type element
        - if ( <[contents-type].equals[inventory]> ):
            - define contents <[contents].list_contents.if_null[<list>]>
            - define contents-type list
        - else if ( <[contents-type].equals[element]> ):
            - if ( <[prefix]> != null ):
                - define inventory <inventory[<[prefix]><[contents].replace_text[regex:<&sp>|-].with[_]>].if_null[null]>
            - else:
                - define inventory <inventory[<[contents].replace_text[regex:<&sp>|-].with[_]>].if_null[null]>
            - if ( <[inventory]> == null ):
                - if ( <[debug]> ):
                    - narrate invalid-inventory-script
                - determine false
            - define contents <[inventory].list_contents.if_null[<list>]>
            - define contents-type list
        # |------- check contents -------| #
        - mark contents-check
        - define contents-size <[missing-contents].if_true[0].if_false[<[contents].size>]>
        - if ( <[missing-contents]> ):
            - if ( <[debug]> ):
                - narrate missing-iterable
            - determine false
        - else if ( <[contents-size]> > 54 ):
            - if ( <[debug]> ):
                - narrate invalid-contents-size
            - determine false
        # |------- parse slots -------| #
        - if ( <[missing-slot]> ):
            - if ( <[debug]> ):
                - narrate missing-slot
            - determine false
        - else if ( <[slot-type].equals[map]> ):
            - if ( <[debug]> ):
                - narrate invalid-struct
            - determine false
        - else if ( <[slot-type].equals[list]> ):
            - define slots <[slot]>
        - else:
            - define slots <list[<[slot]>]>
        - foreach <[slots]> as:slot:
            - define slot-type <[missing-slot].if_true[null].if_false[<[slot].object_type>]>
            - if ( not <[slot-type].equals[element]> ) && ( not <[slot-type].equals[item]> ):
                - if ( <[debug]> ):
                    - narrate invalid-type
            - else if ( <[slot].is_integer.if_null[false]> ):
                # |------- get slots (list of item) -------| #
                - narrate placeholder
            - else if ( <[slot-type].equals[item]> ):
                # |------- get slots (list of int) -------| #
                - define result <[contents].find_all_matches[raw_exact:<[slot]>]>
                - if ( <[slots].size> == 1 ):
                    - determine <[result]>
                - define results:->:<[result]>
            - else if ( <[slot-type].equals[element]> ):
                # |------- get slots (int) -------| #
                - define rows <[contents-size].div[9]>
                - define parsed <[slot].replace_text[regex:<&sp>|_].with[-].split[-].exclude[<&sp>|<empty>].separated_by[-].if_null[<[slot]>]>
                - define actions <list[<[parsed]>]>
                - if ( <[parsed].contains[-]> ):
                    - define actions <[parsed].split[-].if_null[<[actions]>]>
                    - if ( <[actions].size> == 1 ) && ( <[actions].get[1].length> <= 3 ):
                        - define actions <[actions].get[1].to_list>
                - else if ( <[parsed].length> <= 3 ):
                    - define actions <[parsed].to_list>
                #- narrate "rows: <[rows]><&nl>slot: <[parsed]><&nl>actions: <[actions]>"
                - choose <[parsed].if_null[null]>:
                    - case tl t-l t-left top-l top-left:
                        - define result 1
                    - case tr t-r t-right top-r top-right:
                        - define result 9
                    - case bl b-l b-left bottom-l bottom-left:
                        - define result <[rows].mul[9].sub[8]>
                    - case br b-r b-right bottom-r bottom-right:
                        - define result <[rows].mul[9]>
                    - case c cu c-u c-up center-u center-up center:
                        - if ( <[rows].is_even> ):
                            - define result <[rows].sub[1].mul[9].div[2].round>
                        - else if ( <[rows].is_odd> ):
                            - if ( <[actions].contains_any[u|up]> ) && ( <[rows]> != 1 ):
                                - define result <[rows].sub[2].mul[9].div[2].round>
                            - else:
                                - define result <[rows].mul[9].div[2].round>
                    - case cd c-d c-down center-d center-down:
                        - narrate placeholder
                    - case ct c-t c-top center-t center-top:
                        - narrate placeholder
                    - case cb c-b c-bottom center-b center-bottom:
                        - define result <[rows].mul[9].sub[4]>
                    - case cr cru c-r-u c-right center-r center-right center-right-up:
                        - if ( <[rows].is_even> ):
                                - define result <[rows].sub[1].mul[9].div[2].round.add[4]>
                        - else if ( <[rows].is_odd> ):
                            - if ( <[actions].contains_any[u|up]> ) && ( <[rows]> != 1 ):
                                - define result <[rows].sub[2].mul[9].div[2].round.add[4]>
                            - else:
                                - define result <[rows].mul[9].div[2].round.add[4]>
                    - case crd c-r-d center-right-down:
                        - narrate placeholder
                    - case cl clu c-l-u c-left center-l center-left center-left-up:
                        - if ( <[rows].is_even> ):
                            - define result <[rows].sub[1].mul[9].div[2].round.sub[4]>
                        - else if ( <[rows].is_odd> ):
                            - if ( <[actions].contains_any[u|up]> ) && ( <[rows]> != 1 ):
                                - define result <[rows].sub[2].mul[9].div[2].round.sub[4]>
                            - else:
                                - define result <[rows].mul[9].div[2].round.sub[4]>
                    - case cld c-l-d center-left-down:
                        - narrate placeholder
                    - default:
                        - narrate invalid-input(slot)
                - if ( <[result].exists> ):
                    - if ( <[slots].size> == 1 ):
                        - determine <[result]>
                    - define results:->:<[result]>
            - else:
                - determine false
        - determine <[results].if_null[false]>



gui_manager_get_opened:
    ##########################################################
    # | ---  |              get opened              |  --- | #
    ##########################################################
    # | ---                                            --- | #
    # | ---  Required:  none                           --- | #
    # | ---                                            --- | #
    # | ---  Optional:  gui-id                         --- | #
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
    definitions: gui-id
    script:
        # |------- gui data -------| #
        - define opened <player.flag[gui_manager.session.data].keys.if_null[<list>]>
        - if ( <[gui-id].if_null[null]> != null ):
            - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id]>]>
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
    # | ---  Optional:  none                           --- | #
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
    definitions: session-id | gui-id
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        - if ( <[gui-id].if_null[null]> == null ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' -------| #
                - define message "<[log_prefix]> - get.cache() -<&gt> parameter 'gui-id' is missing."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - define cache <player.flag[gui_manager.session.data].get[<[gui-id]>].if_null[null]>
        - if ( <[cache]> == null ):
            - if ( <[debug]> ):
                # |------- missing -------| #
                - define message "<[log_prefix]> - get.cache() -<&gt> gui-id '<[gui-id]>' properties have not been cached."
                - debug log <[message]>
                - log <[message]> type:warning file:<[log_path]>
            - determine false
        # |------- return -------| #
        - determine <[cache]>



gui_manager_get_ast:
    #########################################################
    # | ---  |               get ast               |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  none                          --- | #
    # | ---                                           --- | #
    # | ---  Optional:  none                          --- | #
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
    definitions: session-id
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - if ( <[ast]> == null ):
            - if ( <[debug]> ):
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
    # | ---  Optional:  gui-id | ignore                  --- | #
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
    definitions: session-id | gui-id | ignore
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- data -------| #
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - define built <player.flag[gui_manager.session.built].if_null[<list>]>
        - define inventories <player.flag[gui_manager.session.data].if_null[<map>]>
        # |------- check data -------| #
        - if ( <[gui-id].if_null[null]> == null ) || ( not <[gui-id].object_type.equals[element]> ) || ( not <[built].contains[<[gui-id]>].if_null[false]> ):
            - define gui-id <player.flag[gui_manager.nav.current].if_null[null]>
        - if ( <[ignore].if_null[false]> ) || ( <[built].is_empty> ):
            # |------- ignore -------| #
            - determine <[gui-id].if_null[null]>
        - define filtered <[ast].deep_keys.filter_tag[<[filter_value].split[.].contains[<[gui-id]>]>].include[<[ast].keys.filter_tag[<[filter_value].equals[<[gui-id]>]>]>].if_null[<list>]>
        - define parsed <[filtered].parse_tag[<[parse_value].split[.].first.if_null[<[parse_value].split[.].last>]>].deduplicate.if_null[<list>]>
        - if ( <[parsed].size> > 1 ):
            - if ( <[debug]> ):
                # |------- maximum -------| #
                - define message "<[log_prefix]> - get.root() -<&gt> gui '<[gui-id]>' found too many root nodes and is limited to one (1)."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[parsed].is_empty> ):
            # |------- default -------| #
            - define root <[ast].sort_by_value[size].keys.first.if_null[<[gui-id]>]>
            - if ( <[debug]> ):
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
    # | ---  Optional:  ignore                       --- | #
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
    definitions: session-id | gui-id | ignore
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        - if ( <[gui-id].if_null[null]> == null ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' -------| #
                - define message "<[log_prefix]> - get.parent() -<&gt> gui '<[gui-id]>' parameter 'gui-id' is missing."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine null
        # |------- gui data -------| #
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - define built <player.flag[gui_manager.session.built].if_null[<list>]>
        - define inventories <player.flag[gui_manager.session.data].if_null[<map>]>
        - if ( <[ignore].if_null[false]> ):
            # |------- ignore -------| #
            - determine null
        # |------- ast data -------| #
        - define current <player.flag[gui_manager.nav.current].if_null[null]>
        - if ( <[current]> == null ) || ( <[current]> == <[gui-id]> ):
            - determine null
        - else if ( <[current]> != null ):
            - define filtered <[ast].deep_keys.parse_tag[<[parse_value].split[.]>].filter_tag[<[filter_value].contains[<[gui-id]>]>].if_null[<list>]>
            - if ( <[filtered].is_empty> ):
                - if ( <[debug]> ):
                    # |------- missing -------| #
                    - define message "<[log_prefix]> - get.parent() -<&gt> could not locate '<[gui-id]>' in ast."
                    - debug log <[message]>
                    - log <[message]> type:severe file:<[log_path]>
                - determine null
            - define branch <[filtered].get[1].if_null[<list>]>
            - if ( <[branch].any> ):
                - define parsed <[branch].get[<[branch].find[<[gui-id]>].sub[1].if_null[1]>].if_null[null]>
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
    # | ---  Optional:  ignore                       --- | #
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
    definitions: session-id | gui-id | ignore
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        - if ( <[gui-id].if_null[null]> == null ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' -------| #
                - define message "parameter 'gui-id' is missing."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine null
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - ~run gui_manager path:get.parent def.gui-id:<[gui-id]> save:parent
        - define parent <entry[parent].created_queue.determination.get[1].if_null[null]>
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - define built <player.flag[gui_manager.session.built].if_null[<list>]>
        - define inventories <player.flag[gui_manager.session.data].if_null[<map>]>
        - if ( <[ignore].if_null[false]> ):
            # |------- ignore -------| #
            - determine null
        # |------- parse ast -------| #
        - if ( <[parent]> == null .if_null[ <[parent]> == <empty> ) && ( <[ast].keys> contains <[gui-id]> ):
            # |------- return root nodes -------| #
            - determine <[ast].keys>
        - else if ( <[parent]> != null ):
            - foreach <[ast].deep_keys> as:branch:
                - if ( <[parent]> == <[branch]> ):
                    # |------- return siblings -------| #
                    - define siblings <[ast].get[<[branch]>].keys.if_null[<list>]>
                    - determine <[siblings].keys.exclude[<[gui-id]>].if_null[<list>]>
                - else if ( <[branch].split[.].if_null[<list>]> contains <[gui-id]> ):
                    - foreach <[branch].split[.]> as:leaf:
                        - if ( <[parent]> == <[leaf]> ):
                            # |------- return siblings -------| #
                            - define siblings <[ast].deep_get[<[branch].before[.<[parent]>]>.<[parent]>].if_null[<list>]>
                            - determine <[siblings].keys.exclude[<[gui-id]>].if_null[<list>]>
        # |------- missing siblings -------| #
        - if ( <[debug]> ):
            # |------- missing parameter 'gui-id' -------| #
            - define message "could not locate 'siblings' for '<[gui-id]>'."
            - debug log <[message]>
            - log <[message]> type:severe file:<[log_path]>
        - determine null



gui_manager_get_lineage:
    #########################################################
    # | ---  |             get lineage             |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  gui-id                        --- | #
    # | ---                                           --- | #
    # | ---  Optional:  ignore                        --- | #
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
    definitions: session-id | gui-id | ignore
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        - if ( <[gui-id].if_null[null]> == null ):
            - if ( <[debug]> ):
                # |------- missing parameter 'gui-id' -------| #
                - define message "parameter 'gui-id' is missing."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        # |------- gui data -------| #
        - define gui-id <[gui-id].replace_text[regex:<&sp>|-].with[_].if_null[<[gui-id].if_null[null]>]>
        - ~run gui_manager path:get.parent def.gui-id:<[gui-id]> save:parent
        - define parent <entry[parent].created_queue.determination.get[1].if_null[null]>
        - define ast <player.flag[gui_manager.session.ast].if_null[<map>]>
        - define built <player.flag[gui_manager.session.built].if_null[<list>]>
        - define inventories <player.flag[gui_manager.session.data].if_null[<map>]>
        - if ( <[ignore].if_null[false]> ) || ( not <[built].contains[<[gui-id]>]> && not <[inventories].is_empty> ):
            # |------- ignore -------| #
            - determine null
        - if ( <[ast]> == null ):
            - if ( <[debug]> ):
                # |------- missing ast -------| #
                - define message "could not locate 'ast'. App must be initialized before use."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        # |------- check parent -------| #
        - if ( <[parent]> == null .if_null[ <[parent]> == <empty> ) && ( <[ast].keys> contains <[gui-id]> ):
            # |------- return empty -------| #
            - determine <list>
        # |------- parse lineage -------| #
        - define lineages <[ast].deep_keys.filter_tag[<[filter_value].contains_text[<[gui-id]>]>]>
        - define parsed <[lineages].parse_tag[<[parse_value].split[.].get[1].to[<[parse_value].split[.].find[<[gui-id]>].sub[1].if_null[1]>].separated_by[.]>].deduplicate.if_null[<list>]>
        - if ( <[parsed].is_empty> ):
            - if ( <[debug]> ):
                # |------- maximum -------| #
                - define message "could not locate 'lineage' for '<[gui-id]>'."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        - else if ( <[parsed].size> > 1 ):
            - if ( <[debug]> ):
                # |------- maximum -------| #
                - define message "gui '<[gui-id]>' found in multiple lineages and is limited to one (1)."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
            - determine false
        - determine <[parsed].get[1].split[.].if_null[<list>]>



gui_manager_reset_ast:
    #########################################################
    # | ---  |              reset ast              |  --- | #
    #########################################################
    # | ---                                           --- | #
    # | ---  Required:  none                          --- | #
    # | ---                                           --- | #
    # | ---  Optional:  none                          --- | #
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
    definitions: session-id
    script:
        # |------- flags -------| #
        - define debug <player.flag[gui_manager.debug].if_null[false]>
        - if ( not <[session-id].exists> ):
            - define session-id <player.flag[gui_manager.session.id].if_null[null]>
        - if ( <[debug]> ):
            - ~run gui_manager_log save:log
            - define log_prefix <entry[log].created_queue.determination.get[1].get[1]>
            - define log_path <entry[log].created_queue.determination.get[1].get[2]>
        # |------- reset ast -------| #
        - define cached <player.flag[gui_manager.session.ast].if_null[null]>
        - ~run gui_manager path:build save:build
        - if ( not <entry[build].created_queue.determination.get[1].if_null[false]> ):
            # |------- failed -------| #
            - if ( <[cached]> != null ):
                - flag <player> gui_manager.session.ast:<[cached]>
            - if ( <[debug]> ):
                - define message "<[log_prefix]> - reset.ast() -<&gt> ast reset failed."
                - debug log <[message]>
                - log <[message]> type:severe file:<[log_path]>
        - else if ( <[debug]> ) && ( <player.flag[gui_manager.debug]> ):
            # |------- success -------| #
            - define message "<[log_prefix]> - reset.ast() -<&gt> abstract syntax tree reset."
            - debug log <[message]>
            - log <[message]> type:info file:<[log_path]>



# | ----------------------------------------------  GUI MANAGER | COMMAND  ---------------------------------------------- | #



gui_manager_command:
	##################################################
	# | ---  |        command script        |  --- | #
	##################################################
    type: command
    debug: false
    name: guimanager
    description: Gui Manager library command.
    usage: /guimanager
    aliases:
        - gmanager
        - guim
        - gm
    tab complete:
		# |------- procedural tab completion -------| #
        - if ( <context.raw_args.trim> == <empty> ) || ( <context.args.size> == 1 ) && ( not <context.raw_args.ends_with[<&sp>]> ):
            - define result:|:ast|debug|session|help
        - else:
            - choose <context.args.get[1].if_null[null]>:
                - case session:
                    - define sessions <server.flag[gui_manager.session.ids].if_null[<map>]>
                    - choose <context.args.get[2].if_null[null]>:
                        - default:
                            - define result:|:<list.include[init|end|suspend|list]>
                        - case list:
                            - define result:|:<[sessions].keys>
        - determine <[result].if_null[<list>]>
    script:
		# |------- command data -------| #
        #- define generic <inventory[generic[size=27]]>
        #- define unique <inventory[citizens_editor_gui_skin_editor]>
        #- narrate <[generic]>
        #- narrate <[unique].list_contents>
        #- flag <player> gui_manager.session.generic:true
        #- adjust <[generic]> contents:<list[snowball|stick]>
        #- adjust <[generic]> contents:<list.pad_right[<[generic].size>].replace[<empty>].with[<item[air]>]>
        #- inventory open destination:<[generic]>
        #- narrate <[generic]>
        - define list <list[test|test2|test3]>
        - definemap map:
            test: <empty>
            test2: <empty>
            test3: <empty>
        - define element testing
        - narrate "element: <[element].unescaped><&nl>list: <[list].unescaped.before[<&at>]><&nl>map: <[map].unescaped.before[<&at>]>"












# | ------------------------------------------------------------------------------------------------------------------------------ | #


