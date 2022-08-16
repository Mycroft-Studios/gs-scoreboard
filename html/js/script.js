var config = {}
var onlinePlayers = 0
var isScoreboardOpen = false

function sortTableLetters(n) {
    var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
    table = document.getElementById("usersTable");
    switching = true;
    dir = "asc";
    while (switching) {
        switching = false;
        rows = table.rows;
        for (i = 0; i < (rows.length - 1); i++) {
            shouldSwitch = false;
            x = rows[i].getElementsByTagName("TD")[n];
            y = rows[i + 1].getElementsByTagName("TD")[n];
            if (dir == "asc") {
                if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                }
            } else if (dir == "desc") {
                if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                }
            }
        }
        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
            switchcount++;
        } else {
            if (switchcount == 0 && dir == "asc") {
                dir = "desc";
                switching = true;
            }
        }
    }
}

function sortTableNumbers(n) {
    var table, rows, switching, i, x, y, shouldSwitch;
    table = document.getElementById("usersTable");
    switching = true;
    while (switching) {
        switching = false;
        rows = table.rows;
        for (i = 0; i < (rows.length - 1); i++) {
            shouldSwitch = false;
            x = rows[i].getElementsByTagName("TD")[0];
            y = rows[i + 1].getElementsByTagName("TD")[0];
            if (Number(x.innerHTML) > Number(y.innerHTML)) {
                shouldSwitch = true;
                break;
            }
        }
        if (shouldSwitch) {
            rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
            switching = true;
        }
    }
}

function msToTime(duration) {
  var seconds = Math.floor((duration / 1000) % 60),
    minutes = Math.floor((duration / (1000 * 60)) % 60),
    hours = Math.floor((duration / (1000 * 60 * 60)) % 24);
  if (minutes == 0 && hours == 0){
    return seconds + " Seconds ";
  }
  if (hours == 0) {
    return minutes + " Minutes " + seconds + " Seconds ";
  }
  return hours + " Hours " + minutes + " Minutes " + seconds + " Seconds ";
}

$(document).ready(function() {
    window.addEventListener('message', (event) => {
        let data = event.data
        if(data.action == "getConfig") {
            config = data.config
            loadKeyBinds()
            toggleKeyBinds()
            togglePlayerInfo()
            toggleIllegalActivitesInfo()
        }
        if (data.action == 'show' && !isScoreboardOpen) {
            isScoreboardOpen = true
            $("#main").fadeIn(500);
        }
        if (data.action == 'hide' && isScoreboardOpen) {
            isScoreboardOpen = false
            $("#illegalActivites").empty()
            $("#main").fadeOut(500);
        }
        if (data.action == "updateScoreboard") {
            onlinePlayers = data.onlinePlayers
            $('#onlinePlayers').html(data.onlinePlayers + ' <i class="fa-solid fa-circle-dot  noSelect" style="color: #7CFC00;"></i>')
            $('#onlineStaff').html(data.onlineStaff + ' <i class="fa-solid fa-clipboard-user noSelect" style="color: #5c5c5c;"></i>')
            $('#onlinePolice').html(data.onlinePolice + ' <i class="fa-solid fa-handcuffs noSelect" style="color: #3B9AE1;"></i>')
            $('#onlineEMS').html(data.onlineEMS + ' <i class="fa-solid fa-truck-medical noSelect" style="color: white;"></i>')
            $('#onlineTaxi').html(data.onlineTaxi + ' <i class="fa-solid fa-taxi noSelect" style="color: #fdb813;"></i>')
            $('onlineMechanics').html(data.onlineMechanics + ' <i class="fa-solid fa-toolbox noSelect" style="color: #cd8e52;"></i')
        }
        if (data.action == "addUserToScoreboard") {
            const trElement = document.createElement('tr')
            const td1Element = document.createElement('td')
            const td2Element = document.createElement('td')
            const td3Element = document.createElement('td')
            const td4Element = document.createElement('td')

            trElement.id = "tr-source-"+data.playerID
            td1Element.textContent = data.playerID.toString()
            td1Element.id = "td1"
            td2Element.textContent = data.playerName
            td2Element.id = "td2"
            td2Element.onclick = function(event){clickedPlayerName(data.playerID,data.playerName)}
            td3Element.textContent = data.playerJob
            td3Element.id = "td3"
            td4Element.textContent = data.playerGroup.charAt(0).toUpperCase() + data.playerGroup.slice(1);
            td4Element.id = "td4"

            trElement.appendChild(td1Element)
            trElement.appendChild(td2Element)
            trElement.appendChild(td3Element)
            trElement.appendChild(td4Element)

            document.getElementById("usersTable").appendChild(trElement)
        }
        if (data.action == "refreshScoreboard") {
            $("#usersTable").empty()
        }
        if (data.action == "playerInfoUpdate") {
            $("#playerName").html(data.playerName+' <i class="fa-solid fa-user-tag"></i>')
            $("#roleplayName").html(data.roleplayName+' <i class="fa-solid fa-id-card"></i>')
            $("#playTime").html(msToTime(data.timePlayed)+' <i class="fa-solid fa-clock"></i>')
            $("#playerID").html(data.playerID+' <i class="fa-solid fa-server"></i>')
            loadIllegalActivites()
        }
    })

    document.onkeyup = function(data) {
        if (data.which == 192 && isScoreboardOpen) {
            $.post(`https://${GetParentResourceName()}/closeScoreboard`, JSON.stringify({}))
            $("#main").stop();
            $("#main").stop();
        }
    };

    function loadKeyBinds(){
        var jsonConfig = JSON.parse(config)
        for (let i = 0; i < jsonConfig["keyBinds"].length; i++) {
            let key = JSON.stringify(jsonConfig["keyBinds"][i]["key"])
            let description = JSON.stringify(jsonConfig["keyBinds"][i]["description"])
            const keyBind = document.createElement('span')
            keyBind.id = key+"-"+i.toString()
            keyBind.className = "keyboardKeybind"
            keyBind.innerHTML = (description + " <div class='keyButton'>"+key.toUpperCase()+"</div><br>").replaceAll('"',"")
            document.getElementById("keyboardKeybinds").appendChild(keyBind)
        }
    }

    function loadIllegalActivites(){
        var jsonConfig = JSON.parse(config)
        for (let i = 0; i < jsonConfig["illegalActivites"].length; i++) {
            let id = JSON.stringify(jsonConfig["illegalActivites"][i]["id"]).replaceAll('"',"")
            let title = JSON.stringify(jsonConfig["illegalActivites"][i]["title"]).replaceAll('"',"")
            let description = JSON.stringify(jsonConfig["illegalActivites"][i]["description"]).replaceAll('"',"")
            let groupName = JSON.stringify(jsonConfig["illegalActivites"][i]["group_name"]).replaceAll('"',"")
            let minimumPlayerOnline = parseInt(JSON.stringify(jsonConfig["illegalActivites"][i]["minimum_player_online"]).replaceAll('"',""))
            let minimumGroupOnline = parseInt(JSON.stringify(jsonConfig["illegalActivites"][i]["minimum_group_online"]).replaceAll('"',""))
            fetch(`https://${GetParentResourceName()}/getGroupOnline`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    groupName: groupName
                })
            }).then(resp => resp.json()).then(resp => callBackCompleted(resp));

            function callBackCompleted(groupOnlineAmount){
                const illegalActivity = document.createElement('span')
                const noIcon = ' <i class="fa-solid fa-circle-xmark" style="color: #f34943;"></i>'
                const yesIcon = ' <i class="fa-solid fa-circle-check" style="color: #4ff343;"></i>'
                illegalActivity.id = id+"-"+i.toString()
                illegalActivity.className = "illegalActivity"
                illegalActivity.setAttribute("data-tooltip",description)
                illegalActivity.setAttribute("data-tooltip-position","left")
                if (parseInt(groupOnlineAmount) >= parseInt(minimumGroupOnline) && parseInt(onlinePlayers) >= parseInt(minimumPlayerOnline)) {
                    illegalActivity.innerHTML = title+yesIcon
                }
                else{
                    illegalActivity.innerHTML = title+noIcon
                }
                document.getElementById("illegalActivites").appendChild(illegalActivity)
                document.getElementById("illegalActivites").appendChild(document.createElement('br'))
            }
        }
    }

    function toggleKeyBinds(){
        var jsonConfig = JSON.parse(config)
        var toggleKeyBinds = JSON.stringify(jsonConfig["showKeyBinds"])
        if (toggleKeyBinds == "false") $(".keybindContainer").hide()
    }

    function togglePlayerInfo(){
        var jsonConfig = JSON.parse(config)
        var togglePlayerInfo = JSON.stringify(jsonConfig["showPlayerInfo"])
        if (togglePlayerInfo == "false") $(".playerInfoContainer").hide()
    }

    function toggleIllegalActivitesInfo(){
        var jsonConfig = JSON.parse(config)
        var toggleIllegalActivitesInfo = JSON.stringify(jsonConfig["showIllegalActivites"])
        if (toggleIllegalActivitesInfo == "false") $(".illegalActivitesContainer").hide()
    }

    function clickedPlayerName(source,name) {
        fetch(`https://${GetParentResourceName()}/showPlayerPed`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                playerID: source,
                playerName: name
            })
        });
    }

    function updateTableDimensions() {
        try {
              document.getElementById("th1").style.width = "45px"
              document.getElementById("th2").style.width = document.getElementById("td2").clientWidth.toString() + "px"
              document.getElementById("th3").style.width = document.getElementById("td3").clientWidth.toString() + "px"
              document.getElementById("th4").style.width = document.getElementById("td4").clientWidth.toString() + "px"
        } 
        catch (error) {}
    }

    setInterval(updateTableDimensions, 50)

});