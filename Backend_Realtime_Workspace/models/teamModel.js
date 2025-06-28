import mongoose from "mongoose";

const teamMemberSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "UserInfo", required: true },
  role: { type: String, enum: ["owner", "admin", "member", "viewer"], default: "member" },
  joinedAt: { type: Date, default: Date.now },
  status: { type: String, enum: ["active", "invited", "removed"], default: "active" }
}, { _id: false });

const inviteSchema = new mongoose.Schema({
  email: { type: String, required: true },
  invitedBy: { type: mongoose.Schema.Types.ObjectId, ref: "UserInfo" },
  token: { type: String, required: true },
  invitedAt: { type: Date, default: Date.now },
  status: { type: String, enum: ["pending", "accepted", "expired"], default: "pending" }
}, { _id: false });

const teamSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "UserInfo", required: true },
  members: [teamMemberSchema],
  invites: [inviteSchema]
}, { timestamps: true });

const Team = mongoose.model("Team", teamSchema);

export default Team;
