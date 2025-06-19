#! /usr/bin/env node

// .ipynb -(nbconvert)> .html -(chrome,puppeteer)> .pdf

const path = require('path');
const puppeteer = require('puppeteer');
const { glob } = require('glob');
const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

async function toWslPath(p, toWin = false) {
    const f = toWin ? "-w" : "";
    return (await exec(`wslpath ${f} "${p}"`)).stdout.trim();
}

async function convertNotebooks() {
    // Find all .ipynb files
    const notebooks = await glob('**/*.ipynb', { ignore: '**/node_modules/**' });

    if (notebooks.length === 0) {
        console.log("No .ipynb files found");
        return;
    }

    // Launch Puppeteer once for all conversions
    const win_chrome_path = String.raw`C:\Program Files\Google\Chrome Dev\Application\chrome.exe`;
    const executablePath = await toWslPath(win_chrome_path);
    const browser = await puppeteer.launch({
        executablePath,
        headless: true,

    });
    const page = await browser.newPage();

    for (const notebook of notebooks) {
        try {
            console.log(`Processing: ${notebook}`);

            // Convert notebook to HTML
            const htmlPath = notebook.replace(/\.ipynb$/, '.html');
            await exec(`jupyter nbconvert --to html "${notebook}"`);

            // Get absolute paths
            const absHtmlPath = await toWslPath(path.resolve(htmlPath), true);
            const pdfPath = notebook.replace(/\.ipynb$/, '.pdf');
            const absPdfPath = path.resolve(pdfPath);

            // Convert HTML to PDF
            await page.goto(`file://${absHtmlPath}`, {
                waitUntil: 'networkidle0',
                timeout: 60000
            });

            await page.pdf({
                path: absPdfPath,
                format: 'A3',
                printBackground: true,
                margin: undefined,
            });

            console.log(`✅ PDF generated: ${pdfPath}`);
        } catch (err) {
            console.error(`❌ Error processing ${notebook}:`, err.message);
        }
    }

    await browser.close();
    console.log("Conversion complete");
}

convertNotebooks().catch(console.error);
