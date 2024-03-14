import * as zip from "@zip.js/zip.js";

async function download(selector: string, postfixArg: string) {
    let fs = new zip.fs.FS()

    let imgs = document.body.querySelectorAll(selector)
    console.log(imgs)
    let futs = Array.from(imgs).map(async (img, i) => {
        let link = img.attributes["data-src"].textContent as string
        let filename = i + ".png"
        let resp = await fetch(link + postfixArg, { credentials: "include" })
        let blob = await resp.blob()
        return { filename, blob }
    })
    await Promise.all(futs.map(f => f.then(({ filename, blob }) => {
        fs.addBlob(filename, blob)
    })))

    let name = document.title
    let file = await fs.root.exportBlob()
    let a = document.createElement("a")
    a.download = name + ".zip"
    a.href = window.URL.createObjectURL(file)
    a.dataset.downloadurl = ["application/zip", a.download, a.href].join(":")
    let e = new MouseEvent("click")
    a.addEventListener("click", e => { })
    a.dispatchEvent(e)
}

export { download }
