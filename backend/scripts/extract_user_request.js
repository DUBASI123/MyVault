import fs from 'fs';
import path from 'path';

const logPath = "C:\\Users\\dubas\\.gemini\\antigravity\\brain\\6a3b2464-5d0d-46f4-b451-9dc1969e3362\\.system_generated\\logs\\transcript_full.jsonl";

async function main() {
  console.log("Reading transcript_full.jsonl...");
  const data = fs.readFileSync(logPath, 'utf8');
  const lines = data.split('\n').filter(l => l.trim().length > 0);
  
  // Find the last USER_INPUT step
  let lastUserInput = null;
  for (let i = lines.length - 1; i >= 0; i--) {
    const step = JSON.parse(lines[i]);
    if (step.type === 'USER_INPUT') {
      lastUserInput = step;
      break;
    }
  }
  
  if (lastUserInput) {
    console.log("Found last USER_INPUT at step index:", lastUserInput.step_index);
    const content = lastUserInput.content;
    
    // Extract the Dart code block from the user input
    // The user input contains the code block, let's write the whole content to a temp file first
    fs.writeFileSync("C:\\Users\\dubas\\Desktop\\MyVault\\lib\\features\\internships\\screens\\placement_desk_screen.dart", content);
    console.log("✅ Successfully wrote the complete user request content to placement_desk_screen.dart!");
  } else {
    console.log("❌ Could not find USER_INPUT in transcript.");
  }
}

main().catch(console.error);
