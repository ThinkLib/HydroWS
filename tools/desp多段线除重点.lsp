(prompt "\n��***����߳��ص�***��\n�������DESP�����")
(defun c:DESP( / l Sel data newdata en enp js_n)
  (Setvar "Cmdecho" 0) (Prompt "\n\r����ѡ����Ҫ����Ķ���ߣ�")
  (SetQ Sel (SsGet (list(cons 0 "lwpolyline")))
	L (SsLength Sel) ;;��ȡ����
	m 0 js_n 0
	) (Repeat L
	    (SetQ en (SsName Sel m)
		  data(entget en)
		  n 0
		  enp_js t
		  newdata NIL
		  js nil
		  )
	    (while
	      enp_js
	      (setq enp(nth n data)) ;;���������ѭ�����ҳ��ظ���
	      (if(and (member enp newdata)(= 10(car enp)))
		(progn (setq n (+ n 3) js T) )
		(setq newdata (cons enp newdata)) ;;ɸѡ���룬ȥ�ص�
		)
	      (setq n (1+ n))
	      (setq enp_js(nth n data))
	      )
	    (setq newdata(reverse newdata)
		  m (1+ m)
		  )
	    (entmod newdata) ;;����ͼԪ���õ�û���ظ���Ķ����
	    (if js
	      (setq js_n (1+ js_n))
	      )
	    )
  (Setvar "Cmdecho" 1)
  (princ "\n�����칲������������=")
  js_n
  )