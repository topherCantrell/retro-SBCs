
var ws // The websocket to the server
var vp = document.getElementById("viewText") // The textarea
var text = ""
vp.value = text

function onOpen() {
    ws.send('Enter')    
}

function showKey(evt) {
    // Events coming up from the server
    for(var i=0;i<evt.data.length;++i) {
        c = evt.data[i]
        co = c.charCodeAt(0)    
        text = text.replace('\u2588','')
        
        if(co==0x0A) {
            numspaces = 80 - (text.length % 80)
            for(var i=0;i<numspaces;i++) {
                text += ' '
            }
        } else if(co==0x08) {
            text = text.slice(0,-1)
        } else if(co<32 || co>126) {
            text += '~'
        } 
        else {        
            text += c
           
        }

        text += '\u2588'

        while(text.length>31*80) {
            text = text.slice(80)
        }

    }
     
    vp.value = text    
}

function showKeyOLD(evt) {
    // Events coming up from the server
    c = evt.data
    co = c.charCodeAt(0)    
    //text = text.replace('\u2588','')
    if(co==0x0A) {          
        var numspaces = 80 - text.length % 80      
        for(var i=0;i<numspaces;++i) {
            text += ' '
        }
    } else if(co==0x08) {
        text = text.slice(0,-1)
    } else if(co<32 || co>126) {
        text += '`'
    } else {
        text+=c
    } 
    //text += '\u2588'
    vp.innerText = text
    evt.stopPropagation();
    return false;

    // TODO: cursor character, limit chars so no scroll bar, handle backspace
}

function handleKey(evt) {
    // Keyboard events to be send to the server
    if(evt.key=='Backspace') {
        ws.send(String.fromCharCode(0x08))
    } else if(evt.key=='Enter') {
        ws.send(String.fromCharCode(0x0D))   
    } else if(evt.key.length==1) {
        if(!evt.altKey && !evt.ctrlKey) {
            ws.send(evt.key)
        }
    } else {
        // Ignore other special keys
    }
}

function onStart() {
    ws = new WebSocket('ws://'+document.location.host+'/web-socket')
    ws.onopen = onOpen
    ws.onmessage = showKey
}

onStart()