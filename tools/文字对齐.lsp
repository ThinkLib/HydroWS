;�˳����ܣ������ָ����û�Ҫ����ˡ����У���ֱ���򣩡��ҡ����������У�ˮƽ���򣩵ײ��ķ�;ʽ���룬ͬʱ�ɵ������࣡������������ǿ����õģ�
;˵�����˴��ǵڶ��θ��£���������δ����Bug������λ̳�ѷ���Bug���뷴����

;;; ***���ֶ��� ����ʼ***
(defun c:wzdq ()
  (princ
    "\n���ܣ������ָ����û�Ҫ����ˡ����У���ֱ���򣩡��ҡ����������У�ˮƽ���򣩵ײ��ķ�ʽ���룬ͬʱ�ɵ������༰�ָߣ�\n"
  )
  (setvar "osmode" 15359)
  (setvar "cmdecho" 0)
  (if (not (setq ss (ssget '((0 . "TEXT,MTEXT")))))
    (progn (princ "\nδѡ�����ֶ��󣬳����˳���\n") (exit))
  )
  (command "undo" "be")
  (initget "L R M T B C")
  (if (not (setq kw
                  (getkword
                    "\n��ѡ����뷽ʽ��[��˶���(L)/�����Ķ��루��ֱ����(M)/�Ҷ˶���(R)/��������(T)/�����Ķ��루ˮƽ����(C)/�ײ�����(B)/]<L>"
                  )
           )
      )
    (setq kw "L")
  )
  (initget "Y N")                        ;���û�ѡ���Ƿ��������֮��ļ��
  (if (not
        (setq kwGap
               (getkword "�Ƿ��������֮��ļ�ࣿ[��(Y)/��(N)]<Y>")
        )
      )
    (setq kwGap "Y")
  )
  (if (= kwGap "Y")
    (progn
      (initget 6)
      (if (not
            (setq
              gap (getdist "\n��ָ���Ű������֮��ļ�ࣺ<3.0>")
            )
          )
        (setq gap 3.0)
      )
    )
  )
  (setq        i   0
        lst '()
  )
  (setvar "osmode" 0)
  (vl-load-com)
  (repeat (sslength ss)
    (setq txtentname (ssname ss i))
    (cond
      ((= kw "L")                        ;��˶���
       (progn
         (command "_.justifytext" txtentname "" "ML")
         (wdy_wzdq_Ysort)
       )
      )
      ((= kw "M")                        ;�����Ķ��루��ֱ����
       (progn
         (command "_.justifytext" txtentname "" "MC")
         (wdy_wzdq_Ysort)
       )
      )
      ((= kw "R")                        ;�Ҷ˶���
       (progn
         (command "_.justifytext" txtentname "" "MR")
         (wdy_wzdq_Ysort)
       )
      )
      ((= kw "T")                        ;��������
       (progn
         (command "_.justifytext" txtentname "" "TC")
         (wdy_wzdq_Xsort)
       )
      )
      ((= kw "B")                        ;�ײ�����
       (progn
         (command "_.justifytext" txtentname "" "BC")
         (wdy_wzdq_Xsort)
       )
      )
      ((= kw "C")                        ;�����Ķ��루ˮƽ����
       (progn
         (command "_.justifytext" txtentname "" "MC")
         (wdy_wzdq_Xsort)
       )
      )
    )
    (setq i (1+ i))
  )
;;;�����������ı��еĵ�һ�����ֶ�����Ϊ�ο�����
  (setq        entnam_base  (car (car lst))
        entdata_base (entget entnam_base)
        enttype_base (cdr (assoc 0 entdata_base))
  )
  (if (= enttype_base "TEXT")
    (setq tbox_base  (textbox (list (car entdata_base)))
          ptbl_base  (car tbox_base)
          pttr_base  (cadr tbox_base)
          pt_base    (cdr (assoc 11 entdata_base))
                                        ;��ȡ���ֶ���Ĳ����
          ptx_base   (car pt_base)        ;������X����
          pty_base   (cadr pt_base)        ;������Y����
          ptx_pitch  ptx_base
          pty_pitch  pty_base
          heigh_base (cdr (assoc 40 entdata_base))
          width_base (abs (- (car pttr_base) (car ptbl_base)))
    )                                        ;��Ϊ��������
    (setq pt_base    (cdr (assoc 10 entdata_base))
                                        ;��ȡ���ֶ���Ĳ����
          ptx_base   (car pt_base)        ;������X����
          pty_base   (cadr pt_base)        ;������Y����
          ptx_pitch  ptx_base
          pty_pitch  pty_base
          heigh_base (cdr (assoc 43 entdata_base))
                                        ;ȡ�������ֵ��������ֵ
          width_base (cdr (assoc 42 entdata_base))
    )                                        ;��Ϊ��������
  )
  (setq i 1)
  (repeat (- (length lst) 1)
    (setq entnam_current  (car (nth i lst))
          entdata_current (entget entnam_current)
          enttype_current (cdr (assoc 0 entdata_current))
    )
    (if        (or (= kw "L") (= kw "R") (= kw "M")) ;�����Ҷ���ʱ
      (progn (wdy_wzdq_type)
             (if (= kwGap "Y")
               (setq pty_pitch        (+ pty_pitch
                                   (* 0.5 heigh_base)
                                   (* 0.5 heigh_current)
                                   gap
                                )
                     heigh_base        heigh_current
               )                        ;���û�Ҫ�����ּ������Ϊ��ͬ
               (setq pty_pitch (cadr pt_current))
                                        ;���û�δҪ�����ּ������Ϊ��ͬ����Ϊԭʼֵʱ
             )
             (setq pt (list ptx_base pty_pitch 0))
             (if (= enttype_current "TEXT")
               (entmod (subst (cons 11 pt)
                              (assoc 11 entdata_current)
                              entdata_current
                       )
               )
               (entmod (subst (cons 10 pt)
                              (assoc 10 entdata_current)
                              entdata_current
                       )
               )
             )
      )
    )
    (if        (or (= kw "T") (= kw "B") (= kw "C")) ;���е�
      (progn (wdy_wzdq_type)
             (if (= kwGap "Y")
               (setq ptx_pitch        (+ ptx_pitch
                                   (* 0.5 width_base)
                                   (* 0.5 width_current)
                                   gap
                                )
                     width_base        width_current
               )                        ;���û�Ҫ�����ּ������Ϊ��ͬ
               (setq ptx_pitch (car pt_current))
                                        ;���û�δҪ�����ּ������Ϊ��ͬ����Ϊԭʼֵʱ
             )
             (setq pt (list ptx_pitch pty_base 0))
             (if (= enttype_current "TEXT")
               (entmod (subst (cons 11 pt)
                              (assoc 11 entdata_current)
                              entdata_current
                       )
               )
               (entmod (subst (cons 10 pt)
                              (assoc 10 entdata_current)
                              entdata_current
                       )
               )
             )
      )
    )
    (setq i (1+ i))
  )
  (setvar "osmode" 15359)
  (command "undo" "e")
  (princ)
)

(defun wdy_wzdq_type ()
  (if (= enttype_current "TEXT")
    (setq tbox_current        (textbox (list (car entdata_current)))
          ptbl_current        (car tbox_current)
          pttr_current        (cadr tbox_current)
          pt_current        (cdr (assoc 11 entdata_current))
                                        ;��ȡ���ֶ���Ĳ����
          heigh_current        (cdr (assoc 40 entdata_current))
          width_current        (abs (- (car pttr_current) (car ptbl_current)))
    )                                        ;��Ϊ��������
    (setq pt_current        (cdr (assoc 10 entdata_current))
                                        ;��ȡ���ֶ���Ĳ����
          heigh_current        (cdr (assoc 43 entdata_current))
          width_current        (cdr (assoc 42 entdata_current))
    )                                        ;��Ϊ��������
  )
)
�������ص�����

;;;��X����ȽϽ�������
(defun wdy_wzdq_Xsort ()
  (setq
    inpoint (vlax-get (vlax-ename->vla-object txtentname)
                      'InsertionPoint
            )
  )
  (setq        lst (append
              (list (cons txtentname inpoint))
              lst
            )
  )
  (setq
    lst
     (vl-sort lst
              (function        (lambda        (e1 e2)
                          (if (equal (cadr e1) (cadr e2) 1e-5)
                            (if        (equal (caddr e1) (caddr e2) 1e-5)
                              (< (cadr e1) (cadr e2))
                              (< (caddr e1) (caddr e2))
                            )
                          )
                        )
              )
     )
  )
)
;;;��Y����ȽϽ�������
(defun wdy_wzdq_Ysort ()
  (setq
    inpoint (vlax-get (vlax-ename->vla-object txtentname)
                      'InsertionPoint
            )
  )
  (setq        lst (append
              (list (cons txtentname inpoint))
              lst
            )
  )
  (setq
    lst
     (vl-sort lst
              (function        (lambda        (e1 e2)
                          (if (equal (caddr e1) (caddr e2) 1e-5)
                            (if        (equal (cadr e1) (cadr e2) 1e-5)
                              (< (caddr e1) (caddr e2))
                              (< (cadr e1) (cadr e2))
                            )
                          )
                        )
              )
     )
  )
)