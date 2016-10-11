const mqtt = require('mqtt')  
const clientS = mqtt.connect('mqtt://192.168.100.68')
const clientD = mqtt.connect('mqtt://vidnaya13.ru:8081')

clientS.on('connect', () => {  
    console.log("connected to source mqtt broker")
    clientD.on('connect', () => {  
        console.log("connected to distonation mqtt broker")
        clientS.subscribe('data/#')
    })
})

clientS.on('message', (topic, message) => {  
    console.log(topic+":"+message)
    clientD.publish(topic, message)
})