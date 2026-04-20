# Admin CMS Implementation - TODO

## Steps from Plan:
- [ ] Step 1: Create TODO_ADMIN.md (current)
- [ ] Step 2: Update templates/shared.js - Add localStorage persistence (load/saveTreks), auth functions (get/setUserRole), CRUD (add/update/deleteTrek), image utils (fileToBase64 with resize).
- [ ] Step 3: Update templates/login.html - Add "Admin Mode" checkbox, modify handleLogin to set role.
- [ ] Step 4: Update templates/admin_dashboard.html - Real trek list table, Add/Edit/Delete modals/forms with all fields (images base64 preview).
- [ ] Step 5: Update nav in shared.js - Conditional admin dashboard link if isAdmin.
- [ ] Step 6: Test: Login admin, add trek, verify reflects on treks.html/detail.html, image upload, persistence.
- [ ] Step 7: Complete.

Current progress: Step 1 done. Next: shared.js.
