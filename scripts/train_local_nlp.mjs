import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {train} from '../backend/local_nlp.mjs';

const source = process.argv[2];
if (!source) throw new Error('Usage: node scripts/train_local_nlp.mjs path/to/gen_train.jsonl');
const raw = await readFile(source,'utf8');
const rows = [];
for (const line of raw.split(/\r?\n/).filter(Boolean)) {
  const messages = JSON.parse(line).messages;
  const prompt = messages.find(message => message.role === 'user').content;
  if (!prompt.includes('tipe: scenario\n')) continue;
  const question = JSON.parse(messages.find(message => message.role === 'assistant').content);
  const attack = prompt.match(/attack=(\w+)/)?.[1];
  const severity = prompt.match(/severity=(\w+)/)?.[1];
  const answer = question.options[question.answer];
  if (!answer || !attack || !severity) throw new Error('Invalid scenario training row');
  rows.push({label:`${attack}:${severity}`, text:answer});
}
if (!rows.length) throw new Error('No scenario examples');
const model = {...train(rows), source:'gen_train.jsonl', sourceSha256:createHash('sha256').update(raw).digest('hex'), trainedAt:new Date().toISOString(), limitations:'No human-labeled student answers. Retrieval model learned reference actions; other rubric components are explicit heuristics.'};
const output = new URL('../backend/models/',import.meta.url);
await mkdir(output,{recursive:true});
await writeFile(new URL('local_nlp.json',output),JSON.stringify(model,null,2)+'\n');
console.log(JSON.stringify({trainingRows:model.trainingRows,uniqueReferences:model.uniqueReferences,algorithm:model.algorithm}));
