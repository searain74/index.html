<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>리나 헌터 게임</title>
<style>
body {
    margin: 0;
    overflow: hidden;
    background: linear-gradient(#87CEEB, #ffffff);
    font-family: sans-serif;
}

#gameCanvas {
    display: block;
}

#ui {
    position: absolute;
    top: 10px;
    left: 10px;
    font-size: 22px;
    font-weight: bold;
}

#restartBtn {
    position: absolute;
    top: 10px;
    right: 20px;
    padding: 8px 16px;
    font-size: 18px;
    cursor: pointer;
}
</style>
</head>
<body>

<div id="ui">
점수: <span id="score">0</span>
기회: <span id="chance">3</span>
리나 놓침: <span id="linaMiss">0</span>
</div>

<button id="restartBtn">Restart</button>

<canvas id="gameCanvas"></canvas>

<script>
const canvas = document.getElementById("gameCanvas");
const ctx = canvas.getContext("2d");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

let pigs = [];
let bullets = [];
let score = 0;
let chance = 3;
let linaMiss = 0;
let gameOver = false;

const names = ["리나","라나","누나","리다","루나","로나","리노"];
const lanes = [
    canvas.height * 0.25,
    canvas.height * 0.45,
    canvas.height * 0.65
];

let spawnInterval = 1500;
let pigSpeed = 3;

function spawnPig(){
    if(gameOver) return;

    const name = names[Math.floor(Math.random()*names.length)];
    const lane = lanes[Math.floor(Math.random()*lanes.length)];

    pigs.push({
        x: -60,
        y: lane,
        width: 50,
        height: 40,
        name: name,
        hit: false,
        counted: false
    });
}

setInterval(()=>{
    spawnPig();
    pigSpeed += 0.15;
}, spawnInterval);

const gun = {
    x: canvas.width/2,
    y: canvas.height - 50
};

function shoot(){
    if(gameOver) return;

    bullets.push({
        x: gun.x,
        y: gun.y - 95,
        radius: 5
    });
}

document.addEventListener("keydown",(e)=>{
    if(e.code==="Space"){
        shoot();
    }
});

function checkCollision(b,p){
    return b.x > p.x &&
           b.x < p.x + p.width &&
           b.y > p.y &&
           b.y < p.y + p.height;
}

function update(){

    bullets.forEach(b=>{
        b.y -= 9;
    });

    pigs.forEach(p=>{
        if(!p.hit){
            p.x += pigSpeed;
        }

        if(p.x > canvas.width && !p.counted){
            if(p.name === "리나" && !p.hit){
                linaMiss++;
                document.getElementById("linaMiss").innerText = linaMiss;
                if(linaMiss >= 3){
                    gameOver = true;
                    alert("리나를 3번 놓쳤습니다. 게임 오버!");
                }
            }
            p.counted = true;
        }
    });

    bullets.forEach((b,bi)=>{
        pigs.forEach((p)=>{
            if(!p.hit && checkCollision(b,p)){
                p.hit = true;
                p.counted = true;
                if(p.name === "리나"){
                    score++;
                    document.getElementById("score").innerText = score;
                } else {
                    chance--;
                    document.getElementById("chance").innerText = chance;
                    if(chance <= 0){
                        gameOver = true;
                        alert("기회를 모두 소진했습니다!");
                    }
                }
                bullets.splice(bi,1);
            }
        });
    });

    bullets = bullets.filter(b=>b.y > 0);
    pigs = pigs.filter(p=>p.x < canvas.width + 100);
}

function draw(){

    ctx.clearRect(0,0,canvas.width,canvas.height);

    // =========================
    // 리얼한 라이플 총 그리기
    // =========================

    // 총신
    ctx.fillStyle = "#222";
    ctx.fillRect(gun.x - 4, gun.y - 90, 8, 60);

    // 총구
    ctx.fillStyle = "#111";
    ctx.fillRect(gun.x - 6, gun.y - 95, 12, 8);

    // 몸통
    ctx.fillStyle = "#333";
    ctx.fillRect(gun.x - 20, gun.y - 40, 40, 25);

    // 조준기
    ctx.fillStyle = "#000";
    ctx.fillRect(gun.x - 3, gun.y - 75, 6, 10);

    // 손잡이
    ctx.fillStyle = "#5a3d1e";
    ctx.beginPath();
    ctx.moveTo(gun.x + 10, gun.y - 15);
    ctx.lineTo(gun.x + 20, gun.y + 20);
    ctx.lineTo(gun.x + 5, gun.y + 20);
    ctx.lineTo(gun.x - 2, gun.y - 15);
    ctx.closePath();
    ctx.fill();

    // 개머리판
    ctx.fillStyle = "#4a2e14";
    ctx.beginPath();
    ctx.moveTo(gun.x - 20, gun.y - 35);
    ctx.lineTo(gun.x - 50, gun.y - 10);
    ctx.lineTo(gun.x - 35, gun.y + 10);
    ctx.lineTo(gun.x - 10, gun.y - 15);
    ctx.closePath();
    ctx.fill();

    // =========================
    // 총알
    // =========================
    ctx.fillStyle = "red";
    bullets.forEach(b=>{
        ctx.beginPath();
        ctx.arc(b.x,b.y,b.radius,0,Math.PI*2);
        ctx.fill();
    });

    // =========================
    // 돼지 그리기
    // =========================
    pigs.forEach(p=>{
        if(!p.hit){

            ctx.fillStyle = "pink";
            ctx.beginPath();
            ctx.ellipse(p.x + 25, p.y + 20, 25, 18, 0, 0, Math.PI*2);
            ctx.fill();

            ctx.beginPath();
            ctx.arc(p.x+10,p.y+5,6,0,Math.PI*2);
            ctx.arc(p.x+40,p.y+5,6,0,Math.PI*2);
            ctx.fill();

            ctx.fillStyle="black";
            ctx.beginPath();
            ctx.arc(p.x+18,p.y+18,2,0,Math.PI*2);
            ctx.arc(p.x+32,p.y+18,2,0,Math.PI*2);
            ctx.fill();

            ctx.fillStyle="black";
            ctx.font="bold 24px sans-serif";
            ctx.textAlign="center";
            ctx.fillText(p.name,p.x+25,p.y+25);

        } else if(p.name === "리나") {

            ctx.fillStyle="pink";
            ctx.beginPath();
            ctx.ellipse(p.x + 25, p.y + 20, 25, 18, 0, 0, Math.PI*2);
            ctx.fill();

            ctx.font="24px sans-serif";
            ctx.fillStyle="red";
            ctx.fillText("👅",p.x+25,p.y+20);
            ctx.fillText("꾸엑",p.x+25,p.y-5);
        }
    });
}

function gameLoop(){
    if(!gameOver){
        update();
        draw();
        requestAnimationFrame(gameLoop);
    }
}
gameLoop();

document.getElementById("restartBtn").onclick = ()=>{
    pigs=[];
    bullets=[];
    score=0;
    chance=3;
    linaMiss=0;
    pigSpeed=3;
    gameOver=false;
    document.getElementById("score").innerText=0;
    document.getElementById("chance").innerText=3;
    document.getElementById("linaMiss").innerText=0;
    gameLoop();
}
</script>
</body>
</html>
