import mongoose from "mongoose";

const projectSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  status: { type: String, enum: ["active", "archived", "on-hold"], default: "active" },
  teamId: { type: mongoose.Schema.Types.ObjectId, ref: "Team", required: true },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "UserInfo", required: true },
  collaborators: [{ type: mongoose.Schema.Types.ObjectId, ref: "UserInfo" }],
  tags: [{ type: String }],
  startDate: { type: Date },
  endDate: { type: Date },
  attachments: [{ type: String }] // File URLs
}, { timestamps: true });

const Project = mongoose.model("Project", projectSchema);

export default Project;
