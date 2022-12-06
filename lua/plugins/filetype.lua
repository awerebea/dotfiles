-- import plugin safely
local setup, filetype = pcall(require, "filetype")
if not setup then
  return
end

filetype.setup({
  overrides = {
    extensions = {
      hcl = "terraform",
      tf = "terraform",
      tfvars = "terraform",
      tfstate = "json",
    },
    complex = {
      -- Set the filetype of any full filename matching the regex
      [".terraformrc"] = "terraform",
      ["terraform.rc"] = "terraform",
    },
  },
})
