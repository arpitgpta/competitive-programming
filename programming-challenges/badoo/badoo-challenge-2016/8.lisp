(require :split-sequence)
(use-package :split-sequence)

(defun process ()
  (let* ((g (read))
         (w (read))
         (b (read))
         (available (make-array w))
         (needed (make-array `(,w ,g))))
    (dotimes (i w)
      (setf (aref available i) (read))
      (dotimes (j g)
        (setf (aref needed i j) (read))))
    (let ((string (make-array '(0) :element-type 'base-char :fill-pointer 0 :adjustable t)))
      (with-output-to-string (stream string)
        (format stream "min: 0")
        (dotimes (i w)
          (dotimes (j g)
            (format stream " + ~a l~aa~a" (aref needed i j) i j)))
        (format stream ";~%~%")
        (dotimes (i g)
          (format stream "0")
          (dotimes (j w)
            (format stream " + l~aa~a" j i))
          (format stream " = 1;~%"))
        (format stream "~%")
        (dotimes (i w)
          (format stream "0")
          (dotimes (j g)
            (format stream " + ~a l~aa~a" (aref needed i j) i j))
          (format stream " <= ~a;~%" (aref available i)))
        (format stream "~%")
        (dotimes (i w)
          (dotimes (j g)
            (format stream "0 <= l~aa~a;~%" i j)))
        (values b string)))))

(dotimes (_ (read))
  (multiple-value-bind (b input) (process)
    (with-input-from-string (in input)
      (let ((out-string (make-array '(0) :element-type 'base-char :fill-pointer 0 :adjustable t)))
        (with-output-to-string (out out-string)
          (run-program "/usr/bin/lp_solve" '("-S1") :input in :output out)
          (if (< (count #\Newline out-string) 2)
              (format t "NO~%")
              (let* ((pos (position #\: out-string))
                     (value (read-from-string (subseq out-string (+ 2 pos)))))
                (if (= (round (- value b)) 0)
                    (format t "OK~%")
                    (format t "~a~%" (round (- value b)))))))))))
