;Simple example of bio-inference using PLN by hand.

(use-modules (opencog))
(use-modules (opencog rule-engine))

(load "utilities.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load the atomspace and rules ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(loadf "Lifespan-observations_2015-02-21.scm")
;(set_bio_tvs)

(load "background-knowledge.scm")
(load "pln-config.scm")
(load "substitute.scm")
(load "cog-create-intensional-links.scm")


(display "------------------- LET THE REASONING BEGIN ----------------------\n")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the reasoning begin ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; (1) Apply Member2SubsetRule, to get:
;
;  Subset (SetLink (GeneNode "L"))  (ConceptNode "GO_A")
;  Subset (SetLink (GeneNode "PLAU"))  (ConceptNode "GO_A")

; Apply rule just to the gene MemberLinks
(define gene-memberlinks
    (cog-filter
        'MemberLink
        (append-map cog-incoming-set (cog-get-atoms 'GeneNode))
    )
)
;(display-label "gene-memberlinks" gene-memberlinks)
;(define m2s (cog-apply-rule "pln-rule-member-to-subset" gene-memberlinks))

; Applying rule globally through PM until issue with FC and M2S rule is fixed
(define m2s (cog-bind pln-rule-member-to-subset))

(display "m2s: ")(display m2s)

    ;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
    ;      (SetLink (av 0 0 0)
    ;         (GeneNode "L" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
    ;      )
    ;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
    ;   )
    ;   (SubsetLink (stv 1 0.99999982) (av 0 0 0)
    ;      (SetLink (av 0 0 0)
    ;         (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982) (av 0 0 0))
    ;      )
    ;      (ConceptNode "GO_A" (stv 0.001 0.99999982) (av 0 0 0))
    ;   )

#! The following steps occur in the cog-create-intensional-links command:

(2) Get the supersets of L and of PLAU

    superA:
    ((ConceptNode "GO_A" (stv 0.001 0.89999998))
     (ConceptNode "GO_B" (stv 0.001 0.89999998))
    )

    superB:
    ((ConceptNode "GO_A" (stv 0.001 0.89999998))
     (ConceptNode "GO_B" (stv 0.001 0.89999998))
     (ConceptNode "GO_C" (stv 0.001 0.89999998))
    )


(3) Get the union and intersection of the supersets of L and PLAU

    superIntersection:
    ((ConceptNode "GO_A" (stv 0.001 0.89999998))
     (ConceptNode "GO_B" (stv 0.001 0.89999998))
    )

    superUnion-length: 3


(4) For each common relationship (IOW for each relationship in the supersets
    intersection), create the same inverse relationship.

    (SubsetLink (stv 0.5 0.99999982)
       (ConceptNode "GO_A" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "L" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0.5 0.99999982)
       (ConceptNode "GO_B" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "L" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0.5 0.99999982)
       (ConceptNode "GO_A" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0.5 0.99999982)
       (ConceptNode "GO_B" (stv 0.001 0.89999998))
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )


(5) For each inverse relationship (LinkType A B), create (LinkType (Not A) b)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Todo:
; One of the main issues to be resolved is how to define (Not ConceptNode S), in
; general, which seems to me to be domain specific. Perhaps different
; category/set types can specify formulas to used that define what
; (Not Category_of_Type_X) is.
;
; In the present context, we are defining (Not Gene_Category_S) to be all the
; genes in the system that are not members of S.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO_A" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "L" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO_B" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "L" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO_A" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )
    (SubsetLink (stv 0 0.99999982)
       (NotLink
          (ConceptNode "GO_B" (stv 0.001 0.89999998))
       )
       (SetLink
          (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
       )
    )


(6) Apply to AttractionRule to make AttractionLinks for L and PLAU for each
    common relationship (IOW for each relationship in the supersets
    intersection).

        (AttractionLink (stv 0.5 0.99999982)
           (ConceptNode "GO_A" (stv 0.001 0.89999998))
           (SetLink
              (GeneNode "L" (stv 9.9999997e-06 0.89999998))
           )
        )
        (AttractionLink (stv 0.5 0.99999982)
           (ConceptNode "GO_B" (stv 0.001 0.89999998))
           (SetLink
              (GeneNode "L" (stv 9.9999997e-06 0.89999998))
           )
        )
        (AttractionLink (stv 0.5 0.99999982)
           (ConceptNode "GO_A" (stv 0.001 0.89999998))
           (SetLink
              (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
           )
        )
        (AttractionLink (stv 0.5 0.99999982)
           (ConceptNode "GO_B" (stv 0.001 0.89999998))
           (SetLink
              (GeneNode "PLAU" (stv 9.9999997e-06 0.89999998))
           )
        )


(7) Create IntensionalSimilarityLink via direct evaluation based on
    AttractionLinks and # of members in the union of supersets
    tv.s = average(ASSOC(A,L) OR ASSOC(B,L))
           over all relationships in the union of supersets
!#
(define is-l-plau (cog-create-intensional-links
                    (SetLink (GeneNode "L")) (SetLink (GeneNode "PLAU")))
)
(display-atom "is-l-plau" is-l-plau)

    ;(IntensionalSimilarityLink (stv 0.33333334 0.99999982)
    ;   (SetLink
    ;      (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982))
    ;   )
    ;   (SetLink
    ;      (GeneNode "L" (stv 9.9999997e-06 0.99999982))
    ;   )
    ;)

(display "\n\n==================================================================\n")


; (8) Apply singleton-similarity-rule to get
;
; IntensionalSimilarity PLAU L

(define is2-l-plau (cog-bind pln-rule-singleton-similarity))
(display-atom "is2-l-plau" is2-l-plau)

        ;   (IntensionalSimilarityLink (stv 0.33333334 0.99999982)
        ;      (GeneNode "PLAU" (stv 9.9999997e-06 0.99999982))
        ;      (GeneNode "L" (stv 9.9999997e-06 0.99999982))
        ;   )


; (9) Apply gene-similarity2overexpression-equivalence knowledge rule to get
;
; IntensionalEquivalence
;    Pred "Gene-PLAU-overexpressed-in"
;    Pred "Gene-L-overexpressed-in"

(define IE (cog-bind gene-similarity2overexpression-equivalence))
(display-atom "IE" IE)

    ;   (IntensionalEquivalenceLink (stv 0.33333334 0.99999982)
    ;      (PredicateNode "Gene-PLAU-overexpressed-in")
    ;      (PredicateNode "Gene-L-overexpressed-in")
    ;   )
    ;   (IntensionalEquivalenceLink (stv 0.33333334 0.99999982)
    ;      (PredicateNode "Gene-L-overexpressed-in")
    ;      (PredicateNode "Gene-PLAU-overexpressed-in")
    ;   )

; Todo: Ben does this step by applying Modus rule, but can that be done with an
; implication link with vars?

; Todo: Would it work to use a general (Predicate "overexpressed-in" gene $X)
; rather than gene specific predicates?

; Question: are the results of this step supposed to contain ExecutionOutLinks
; rather than the Predicates themselves?


; (10) Apply intensional-equivalence-transformation to get
;
; IntensionalImplication PredNode
;    PredNode "Gene-PLAU-overexpressed-in"
;    PredNode "Gene-L-overexpressed-in"
;
;Todo: check with Ben re sim2inh rule referenced in the word doc

(define II (cog-bind pln-rule-intensional-equivalence-transformation))
(display-atom "II" II)

;      (IntensionalImplicationLink (stv 0.33333334 0.99999982)
;         (PredicateNode "Gene-L-overexpressed-in")
;         (PredicateNode "Gene-PLAU-overexpressed-in")
;      )
;      (IntensionalImplicationLink (stv 0.33333334 0.99999982)
;         (PredicateNode "Gene-PLAU-overexpressed-in")
;         (PredicateNode "Gene-L-overexpressed-in")


; ** first either need to convert first Implication to IntensionalImplication
; or 2nd IntensionalImplication to Implication

; (11) Apply implication-deduction to get
;
; IntensionalImplication PredNode "Gene-L-overexpressed"  PredNode "LongLived"

(define to-long-life (cog-bind pln-rule-deduction-intensional-implication))
(display-atom "to-long-life" to-long-life)

    ;   (IntensionalImplicationLink (stv .25 0.69999999)
    ;      (PredicateNode "Gene-L-overexpressed-in")
    ;      (PredicateNode "LongLived")
    ;   )


; (12) Apply implication-conversion to get
;
; ImplicationLink
;   ExOut Schema "make-overexpression" (GeneNode L)
;   PredNode "LongLived"

(define grounded-conversion-rule
    (substitute pln-rule-intensional-implication-conversion
        (list (cons (VariableNode "$B") (PredicateNode "LongLived")))))
;(define conclusion (cog-bind pln-rule-intensional-implication-conversion))
(define conclusion (cog-bind grounded-conversion-rule))
(display-atom "conclusion" conclusion)

    ;   (ImplicationLink (stv 0.25 0.48999998)
    ;      (PredicateNode "Gene-L-overexpressed-in")
    ;      (PredicateNode "LongLived")
    ;   )
