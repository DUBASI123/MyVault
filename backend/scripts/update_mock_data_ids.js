import fs from 'fs';
import path from 'path';

function getCollegeUuid(numStr) {
  const num = parseInt(numStr, 10);
  const hex = (num + 256).toString(16).padStart(12, '0');
  return `00000000-0000-0000-0000-${hex}`;
}

function getUniUuid(numStr) {
  const num = parseInt(numStr, 10);
  const hex = num.toString(16).padStart(12, '0');
  return `00000000-0000-0000-0000-${hex}`;
}

async function main() {
  const mockDataPath = path.resolve('../lib/core/mock/mock_data.dart');
  if (!fs.existsSync(mockDataPath)) {
    console.error('Could not find MockData.dart at:', mockDataPath);
    process.exit(1);
  }

  let content = fs.readFileSync(mockDataPath, 'utf8');

  // 1. Replace university IDs and universityId: 'X'
  content = content.replace(/(universityId|id):\s*['"]([1-6])['"]/g, (match, field, numStr) => {
    const uuid = getUniUuid(numStr);
    return `${field}: '${uuid}'`;
  });

  // 2. Replace college IDs (id: 'cY') and collegeId: 'cY'
  content = content.replace(/(collegeId|id):\s*['"]c(\d+)['"]/g, (match, field, numStr) => {
    const uuid = getCollegeUuid(numStr);
    return `${field}: '${uuid}'`;
  });

  fs.writeFileSync(mockDataPath, content);
  console.log('Successfully updated MockData.dart university and college IDs to UUID format.');
}

main().catch(console.error);
