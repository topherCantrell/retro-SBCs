
function onStart() {
    ws = new WebSocket('ws://'+document.location.host+'/web-socket')
    //ws = new WebSocket('ws://10.0.0.15/web-socket')
    ws.onopen = function() {
        ws.send('READY\n')
    }
    ws.onmessage = function(evt) {
        console.log(evt.data)  
        document.getElementById("viewText").value += evt.data;
    }
}

function handleKey(evt) {
    ws.send(evt.key)
}

onStart()