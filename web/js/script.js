function showDeathScreen() {
    const titles = [
        "You Are Unconscious",
        "You’ve Gone Unresponsive",
        "Critical Condition",
        "You Are Incapacitated",
        "Trauma Detected"
    ];
    const subtitles = [
        "You're losing consciousness... EMS has been notified.",
        "Everything's going dark... hang in there.",
        "You're in critical condition. Hold on.",
        "You feel your body shutting down... help may be coming.",
        "You're slipping away. EMS might still reach you.",
        "Time is running out... stay strong."
    ];

    const randomTitle = titles[Math.floor(Math.random() * titles.length)];
    const randomSubtitle = subtitles[Math.floor(Math.random() * subtitles.length)];

    $("#mainTitle").text(randomTitle);
    $("#subTitle").text(randomSubtitle);

    $("#deathScreen").removeClass("hidden");

    const currentTime = new Date();
    $("#deathTime").text(currentTime.toLocaleTimeString());

    let timer = 10;
    $("#respawnTimer").text(timer);
    const interval = setInterval(() => {
        timer--;
        $("#respawnTimer").text(timer);
        if (timer <= 0) {
            clearInterval(interval);
            $("#respawn").prop("disabled", false);
            $("#respawnTimer").text("Now");
        }
    }, 1000);
}


const messages = [
    "I've been badly injured, I need help!",
    "I'm bleeding out, please send someone!",
    "I've had a terrible accident, I need EMS!",
    "I can't move... please hurry!",
    "This might be my last chance... help me!"
];

$("#callEms").on("click", function () {
    $("#helpTextContainer").removeClass("hidden")

    const randomMsg = messages[Math.floor(Math.random() * messages.length)];

    $.post(`https://ars_ambulancejob/sendDistressCall`, JSON.stringify({ msg: randomMsg }));
});

$("#respawn").on("click", function () {
    $.post("https://ars_ambulancejob/respawnPlayer");
    $("#deathScreen").addClass("hidden");
});

// For testing
// setTimeout(showDeathScreen, 1000);

window.addEventListener('message', function (event) {
    const { data } = event

    if (data.action === "deathScreen") {
        console.log(data.data)
        if (data.data) {
            showDeathScreen()
        } else {
            $("#deathScreen").addClass("hidden")
        }
    } else {


    }

})

$('.ind').on('click', () => {
    changeSpawnPoint("backward");
});

$('.ava').on('click', () => {
    changeSpawnPoint("forward");
});






function OpenPgList(index) {
    $.post('https://ars_login/action', JSON.stringify({
        tipo: 'charactersList',
        ide: userDati[index].ide
    }), function (data) {
        $('.users').fadeOut();
        setTimeout(() => {
            OpenPgListHtml(data)
        }, 400)
    })
}





$(document).keyup(function (e) {
    if (e.key === 'Escape') {
        if (inputChangePg === true) {
            $('.pannel').removeClass("blur-sm")
            $('.setPg').fadeOut()
            inputChangePg = false
        } else if (pannelOpen === true) {
            $('.pannel').fadeOut();
            $('.back').fadeOut();
            $('.pg-list').fadeOut();
            $('.users').fadeOut();
            $.post("https://ars_login/action", JSON.stringify({
                tipo: "close",
            }));
        }
    }
})
