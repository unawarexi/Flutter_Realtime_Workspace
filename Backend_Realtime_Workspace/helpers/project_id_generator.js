import { v4 as uuidv4 } from "uuid";

// Generate a project key: PROJ{uuid}KEY
export function generateProjectKey() {
  return `PROJ${uuidv4()}KEY`;
}

// Generate a team id: TEAMSPOT{uuid}
export function generateTeamId() {
  return `TEAMSPOT${uuidv4()}`;
}
