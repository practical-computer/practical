import path from 'path';
import fs from 'fs';
import {glob} from 'glob'
import { rollup } from 'rollup'
import resolve from "@rollup/plugin-node-resolve"
import commonjs from '@rollup/plugin-commonjs';

const isWatchCommand = process.argv.includes('--watch')
const buildDirectory = path.join(process.cwd(), "app/assets/builds")

const javascriptDirectory = "test/dummy/app/javascript"

const getEntrypointsMapping = async () => {
  const entrypoints = await glob(path.join(process.cwd(), javascriptDirectory, "*.js"))

  var mapping = {}

  entrypoints.forEach(x => {
    mapping[path.basename(x, '.js')] = x
  })

  return mapping
}

const buildEntrypoints = async () => {
  const inputs = await getEntrypointsMapping()

  var outputPlugins = [resolve(), commonjs()]

  const inputOptions = {
    input: inputs,
    plugins: outputPlugins
  }

  const outputOptions = {
    dir: "test/dummy/app/assets/builds/",
    format: "esm",
    sourcemap: true,
    chunkFileNames: "[name]-[hash].digested.js"
  }

  let bundle;
  try {
    bundle = await rollup(inputOptions);
    const { output } = await bundle.write(outputOptions);
    console.log("✅ build succeeded")
  } catch (error) {
    console.error(error);
  }

  if (bundle) {
    await bundle.close();
  }
}

const build = async (config) => {
  const result = await Bun.build(config);

  if (!result.success) {
    if (isWatchCommand) {
      console.error("🚨 Build failed");
      for (const message of result.logs) {
        console.error(message);
      }
      return;
    } else {
      throw new AggregateError(result.logs, "Build failed");
    }
  }

  return result
};

const buildAll = async () => {
  await buildEntrypoints();
}

(async () => {
  await buildAll()

  if (isWatchCommand) {
    fs.watch(path.join(process.cwd(), javascriptDirectory), { recursive: true }, (eventType, filename) => {
      console.log(`File changed: ${filename}. Rebuilding...`);
      buildAll();
    });
  } else {
    process.exit(0);
  }
})();
