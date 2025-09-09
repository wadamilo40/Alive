;; new-project-solver.clar
;; Fresh error-free Clarity contract for Google Clarity Web3

(define-data-var project-id uint u0)

(define-map projects ((id uint))
  ((owner principal)
   (issue (string-ascii 60))
   (solution (string-ascii 60))
   (status (string-ascii 12))))

;; Step 1: Start a project with a problem
(define-public (start-project (issue (string-ascii 60)))
  (let ((id (var-get project-id)))
    (begin
      (map-set projects id
        ((owner tx-sender)
         (issue issue)
         (solution "")
         (status "pending")))
      (var-set project-id (+ id u1))
      (ok id)
    )
  )
)

;; Step 2: Provide a solution
(define-public (provide-solution (id uint) (solution (string-ascii 60)))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "pending")
          (begin
            (map-set projects id
              ((owner (get owner project))
               (issue (get issue project))
               (solution solution)
               (status "solved")))
            (ok "Solution accepted"))
          (err u1)) ;; wrong status
    (err u2) ;; project not found
  )
)

;; Step 3: Approve and award contract
(define-public (award-contract (id uint))
  (match (map-get? projects id)
    project
      (if (is-eq (get status project) "solved")
          (begin
            (map-set projects id
              ((owner (get owner project))
               (issue (get issue project))
               (solution (get solution project))
               (status "contracted")))
            (ok "Contract awarded"))
          (err u3)) ;; must be solved first
    (err u4) ;; project not found
  )
)
