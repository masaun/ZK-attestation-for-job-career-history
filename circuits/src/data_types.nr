// @dev - Career historical data and Skills data
pub struct JobCareerAndSkillData {
    job_title_hash: Field,         // @dev - Hash of the job title (e.g. Hashed "Software Engineer").
    skill_hashes: [Field; 4],      // @dev - List of skill hashes (e.g. Hashed ["Rust", "ZK", "React"]).
    job_title_commitment: Field,   // @dev - Commitment Hash of the job title to reveal (can be nullified if redacting).
    skill_commitments: [Field; 4],  // @dev - Commitment Hashes of the revealed skills.
    skills_combined_commitment: Field // @dev - Commitment Hash of the combined skills (can be nullified if redacting).
}

pub struct RevealedData {
    nullifier: Field,
    job_title_commitment: Field,
    skills_combined_commitment: Field
}