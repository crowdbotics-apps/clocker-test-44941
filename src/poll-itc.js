require("./string-utilities.js")
const poster = require("./post-update.js")
var admin = require("firebase-admin");

var serviceAccount = require("./app-store-connect-notifier-firebase-adminsdk-29t69-88981729ae.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://app-store-connect-notifier-default-rtdb.firebaseio.com"
});
const dab = admin.database();

const debug = false
var pollIntervalSeconds = process.env.POLL_TIME_IN_SECONDS

function checkAppStatus() {
    let rawData = '';
    try {
        const spawn = require("child_process").spawn
        const rubyProcess = spawn("ruby", ["src/fetch_app_status.rb"]);

        rubyProcess.stdout.on("data", (data) => {
            rawData += data;
        });
        
        // Listen for errors from the Ruby script
        rubyProcess.stderr.on("data", (data) => {
            console.error(`Ruby script error: ${data}`);
        });
        
        rubyProcess.on('close', (code) => {
            const versions = JSON.parse(rawData)
            for (let version of versions) {
                _checkAppStatus(version)
            }
        });
          
        rubyProcess.on('exit', (code) => {
            //console.log(`child process exited with code ${code}`);
        });
    }catch(error) {
        console.log(error);
    }
    
}

async function _checkAppStatus(currentAppInfo) {
    const appInfoKey = "appInfo-" + currentAppInfo.id
    //let datarecordItem = await database.getObjectDefault("/"+appInfoKey, "defaultValue");

    const snapshot = await dab.ref(appInfoKey).once('value');
    const datarecordItem = snapshot.val();
    //console.log(datarecordItem);
    
    if(!datarecordItem){
        //database.push("/"+appInfoKey,currentAppInfo);
        await dab.ref(appInfoKey).set(currentAppInfo);
    }else{
        if (currentAppInfo?.app_store_versions.length > 0) {
            let buildChanged = false
            currentAppInfo.app_store_versions.forEach((buildInfo) => {
                if(datarecordItem.app_store_versions.some(oneBuild => oneBuild.id === buildInfo.id)) {  
                    const matchingBuild = datarecordItem.app_store_versions.find(oneBuild => oneBuild.id === buildInfo.id);
                    if(matchingBuild.app_store_state != buildInfo.app_store_state){
                        buildChanged = true
                        poster.slackBuild(currentAppInfo, buildInfo)
                    }
                }else{
                    buildChanged = true
                    poster.slackBuild(currentAppInfo, buildInfo)
                }
            })
            if(buildChanged){
                await dab.ref(appInfoKey).set(currentAppInfo);
                //database.push("/"+appInfoKey,currentAppInfo);
            }
        }
    }
}

if (!pollIntervalSeconds) {
    pollIntervalSeconds = 60 * 2
}

setInterval(checkAppStatus, pollIntervalSeconds * 1000)
checkAppStatus()
