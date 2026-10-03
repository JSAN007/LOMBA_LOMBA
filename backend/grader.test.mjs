import {test} from 'node:test';
import assert from 'node:assert/strict';
import {validateGrade, gradeAnswer, authenticate, server} from './grader.mjs';

test('Server computes total score instead of accepting a client/model total', () => {
  const value = validateGrade({accuracy:10, priorities:15, reasoning:20, verification:5, feedback:'Perbaiki urutan.', improvements:['Verifikasi hasil.'], score:100});
  assert.equal(value.score, 50);
  assert.equal(value.skillLevel, 'Menengah');
  assert.throws(() => validateGrade({...value, accuracy:26}), /invalid-grade/);
  assert.throws(() => validateGrade({...value, verification:NaN}), /invalid-grade/);
});

test('Grading uses Responses API with authoritative task and structured rubric', async () => {
  const question = {scenario:'Skenario', log:'attack=DDoS', task:'Tangani insiden.', explanation:'Referensi'};
  const result = await gradeAnswer(question, 'Jawaban pemain', async (url, options) => {
    assert.equal(url, 'https://api.openai.com/v1/responses');
    const body = JSON.parse(options.body);
    assert.equal(body.store, false);
    assert.equal(body.text.format.strict, true);
    assert.equal(JSON.parse(body.input).task, question.task);
    assert.equal(JSON.parse(body.input).studentAnswer, 'Jawaban pemain');
    return {ok:true, json:async () => ({status:'completed', output:[{content:[{type:'output_text', text:JSON.stringify({accuracy:20, priorities:10, reasoning:15, verification:5, feedback:'Feedback', improvements:[]})}]}]})};
  });
  assert.equal(result.score, 50);
});

test('API quota errors and incomplete responses do not produce fake grades', async () => {
  await assert.rejects(gradeAnswer({}, 'Jawaban', async () => ({ok:false, status:429, json:async () => ({error:{code:'rate_limit_exceeded'}})})), /provider-rate-limit/);
  await assert.rejects(gradeAnswer({}, 'Jawaban', async () => ({ok:false, status:429, json:async () => ({error:{code:'insufficient_quota'}})})), /api-quota/);
  await assert.rejects(gradeAnswer({}, 'Jawaban', async () => ({ok:true, json:async () => ({status:'incomplete'})})), /invalid-grade/);
});

test('Unsigned/wrong-project tokens are rejected before reading certificates', async () => {
  const token = [Buffer.from(JSON.stringify({alg:'none'})).toString('base64url'), Buffer.from(JSON.stringify({aud:'lomba-b1608', sub:'user'})).toString('base64url'), 'fake'].join('.');
  await assert.rejects(authenticate(token), /unauthorized/);
});

test('Local HTTP routes are reachable but grading requires authentication', async () => {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    const health = await fetch(`${base}/health`);
    assert.equal(health.status, 200);
    assert.equal((await health.json()).status, 'ok');
    const grade = await fetch(`${base}/grade`, {method:'POST', body:'{}'});
    assert.equal(grade.status, 401);
    const crossOrigin = await fetch(`${base}/health`, {headers:{Origin:'https://unknown.example'}});
    assert.equal(crossOrigin.status, 403);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
